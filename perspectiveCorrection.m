function [result] = perspectiveCorrection(image)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Start by generating a mask (bound) for each staff with
    % properties sorted from top to bottom.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make islands of staffs
    staffsMask = extractLinesByAngle(image, 10, 1);
    staffsMask = imopen(staffsMask, strel('disk', 16, 4));
    staffsMask = (staffsMask < graythresh(staffsMask));
    
    % Use mask to identify each staff and orientation
    props = regionprops(staffsMask, 'Centroid', 'Orientation', 'MajorAxisLength');
    staffCount = size(props, 1);
    if staffCount == 0
       result = image;
       return; 
    end
    
    % Sort props based on centroid y-values
    centroids = cat(1, props.Centroid);
    [sorted, sort_order] = sort(centroids(:,2));
    props = props(sort_order);
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Based on the mask properties, generate start/end points 
    % for perspective correction.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    staffs = [];
    edgesOfMask = edge(staffsMask, 'sobel');
    [gridX, gridY] = meshgrid(1:size(image,2), 1:size(image,1));
    for j=1:staffCount   
        % Vertical staffs are not supported
        if props(j).Orientation == 90
            continue; 
        end
        
        % Detect if any centroid is too close to the edge of the
        % image border. It means the staff could be a false positive 
        % and should be discarded. (the center of the staff can't be
        % this close to the edge without being cropped)
        centroid = props(j).Centroid;
        cx = centroid(1,1);
        cy = centroid(1,2);
        widthLimit = floor(size(image,2)*0.05);
        heightLimit = floor(size(image,1)*0.05);
        if cx < widthLimit || cx > (size(image,2)-widthLimit) || ...
           cy < heightLimit || cy > (size(image,1)-heightLimit)
           %disp("Found false positive");
           continue;
        end
        
        
        % Determine the direction of the line going through the center
        % of the staff.
        theta = props(j).Orientation * pi/180;
        R = [ cos(theta)   sin(theta)
             -sin(theta)   cos(theta)];
        lineDir = R*[props(j).MajorAxisLength; 0];
        
        % Use the centroid and direction to generate start/end points
        % for the line. 
        dy = lineDir(2,1) / lineDir(1,1);
        yOffset = centroid(1,2)-dy*centroid(1,1);
        
        % intersection between the line and the outer edge of the staff
        lineMask = (gridY == round(gridX.*dy + yOffset));
        [pointsY, pointsX] = find(and(edgesOfMask, lineMask));
        % failed to find intersection points
        if isempty(pointsY)
            continue;
        end
        
        % convert intersection points to start and end points.
        % Sometimes multiple points are returned, so we pick the extremes.
        startX = centroid(1,1); startY = centroid(1,2);
        endX = startX; endY = startY;
        middleX = centroid(1,1);
        for p=1:size(pointsX,1)
            pointOnLeftSide = (pointsX(p) < middleX);
            if pointOnLeftSide && pointsX(p) < startX
                startX = pointsX(p);
                startY = pointsY(p);
            elseif ~pointOnLeftSide && pointsX(p) > endX
                endX = pointsX(p);
                endY = pointsY(p);
            end
        end
        
        
        newStaff = struct;
        
        newStaff.x1 = startX;
        newStaff.y1 = startY;
        newStaff.x2 = endX;
        newStaff.y2 = endY;
        newStaff.angle = props(j).Orientation;
        newStaff.centroid = struct("x", centroid(1,1), "y", centroid(1,2));
        
        newStaff.direction = struct("x", endX-startX,  "y", endY-startY);
        newStaff.length = sqrt(newStaff.direction.x^2 + newStaff.direction.y^2);
        newStaff.direction.x = newStaff.direction.x/newStaff.length;
        newStaff.direction.y = newStaff.direction.y/newStaff.length;
        
        staffs = [staffs; newStaff];
    end
    staffCount = size(staffs,1);
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine if the image has a perspective. First determine if staffs
    % are parallel. If they are nearly parallel we also have to check if
    % the corner angles are nearly perpendicular.
    %
    % If any angles are deviating beyond 1 degree, we assume that there
    % is a perspective present.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hasPerspective = false;
    
    % Determine if the staffs are parallel by testing if any staff deviates 
    % from the first one by more than 1 degree.
    for j=2:staffCount
        if abs(staffs(j).angle-staffs(1).angle) > 1
            hasPerspective = true;
            break;
        end
    end
    
    if ~hasPerspective
        % The staffs are parallel. We still have to check if the corners
        % are perpendicular. (some photos can have perfectly horizontal 
        % staffs but with a perspective present, which bends the corners)
        
        % Create two vectors from the corner of the first staff and
        % check the angle between them.
        % x --> v   -&-------|-------------|
        % |         -&----------|----------|
        % V         -&-----|---------------|
        % u         -&-------|
        u = [(staffs(end).x1 - staffs(1).x1), (staffs(end).y1 - staffs(1).y1), 0];
        v = [(staffs(1).x2-staffs(1).x1), (staffs(1).y2-staffs(1).y1), 0];
        angle = atan2(norm(cross(u,v)),dot(u,v))/pi * 180;
        
        % Assume that any angle deviating by more than 1 degree 
        % implies that a perspective is present.
        hasPerspective = abs(angle-90) > 1;
    end
    
    % DEBUG
    %if hasPerspective
    %    disp("Perspective detected");
    %else
    %    disp("Orthogonal");
    %end
    
    if ~hasPerspective
        % All staffs are parallel and the corners are perpendicular.
        % It is VERY likely to be a scanned paper with no perspective.
        result = 1-imrotate(1-image, -staffs(1).angle, 'bicubic');
        return;
    end
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine the outer bounds of the staffs. This will become the
    % target size when aligning points for perspective correction.
    %
    % Also remember longest dimensions so that we size up, not down.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    farLeft = size(image, 2); farRight = 0;
    leftTop = size(image, 1); leftBottom = 0;
    rightTop = size(image, 1); rightBottom = 0;
    longestStaff = 0;
    longestColumn = 0;
    for j=1:staffCount
        farLeft = min(farLeft, staffs(j).x1);
        leftTop = min(leftTop, staffs(j).y1);
        leftBottom = max(leftBottom, staffs(j).y1);
        
        farRight = max(farRight, staffs(j).x2);
        rightTop = min(rightTop, staffs(j).y2);
        rightBottom = max(rightBottom, staffs(j).y2);
        
        longestStaff = max(longestStaff, staffs(j).length);
    end
    leftHeight = leftBottom-leftTop;
    rightHeight = rightBottom-rightTop;    
    maxHeight = max(leftHeight, rightHeight);    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Skip the last staff as it can vary in length.
    % TODO: A single staff might still be skewed after running this
    %       function.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if staffCount > 1
        staffCount = staffCount-1;
        staffs = staffs(1:staffCount);
    end
    
    % Create a second set of staffs. These staffs are "straightened out"
    % and will be used as a target for warping the image.
    adjustedStaffs = staffs;
    
    % Snap all points to the sides
    for j=1:staffCount
       adjustedStaffs(j).x1 = farLeft;
       adjustedStaffs(j).x2 = farRight;
    end
    
    % Move left points upwards to origo -> scale.
    % Right points height are simply flattened to match the left.
    scale = maxHeight / leftHeight;
    for j=1:staffCount
       adjustedStaffs(j).y1 = (adjustedStaffs(j).y1-leftTop)*scale;
       adjustedStaffs(j).y2 = adjustedStaffs(j).y1;
    end
    
    % Convert staffs to points that can be used by fitgeotrans
    points=[];
    targetPoints=[];
    for j=1:staffCount
        points = [points; staffs(j).x1, staffs(j).y1; staffs(j).x2, staffs(j).y2];
        targetPoints = [targetPoints; adjustedStaffs(j).x1, adjustedStaffs(j).y1; adjustedStaffs(j).x2, adjustedStaffs(j).y2];
    end
    
    % Apply the final transformation
    tform = fitgeotrans(points, targetPoints, 'projective');
    result = 1-imwarp(1-image, tform, 'cubic');
end

