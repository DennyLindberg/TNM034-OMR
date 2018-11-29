function [individualStaffs, staffCount] = splitStaffsBasedOnMask(image, staffsMask)  
    % Default return values
    individualStaffs = [];
    staffCount = 0;
    
    % Detect that input dimensions agree
    imageWidth = size(image, 2);
    imageHeight = size(image, 1);
    maskWidth = size(staffsMask, 2);
    maskHeight = size(staffsMask, 1);
    if imageWidth == 0 || imageHeight == 0 || maskWidth == 0 || maskHeight == 0 || ...
       imageWidth ~= maskWidth || imageHeight ~= maskHeight
        return;
    end
    
    % Extract properties (exit early if no properties found)
    props = regionprops(staffsMask, 'BoundingBox');
    staffCount = size(props, 1);
    if staffCount == 0; return; end
    
    % Sort props based on bounding box vertical order
    bboxes = cat(1, props.BoundingBox);
    if staffCount > 0
        top_edge = bboxes(:, 2);
        [sorted, sort_order] = sort(top_edge);
        props = props(sort_order);
    end
    
    % Generate list of boxes for easier processing
    bboxes = [];
    for i=1:staffCount   
        bbox = props(i).BoundingBox;
        x1 = floor(bbox(1));
        y1 = floor(bbox(2));
        x2 = x1 + floor(bbox(3));
        y2 = y1 + floor(bbox(4));
        
        cx = round((x1+x2)/2);
        cy = round((y1+y2)/2);
        limitX = imageWidth*0.02;
        limitY = imageHeight*0.02;
        if cx < limitX || cx > (imageWidth-limitX) || ...
           cy < limitY || cy > (imageHeight-limitY)
           %disp("Removed bad staff, the midpoint was too close to the image border");
           continue;
        end
        
        box = struct;
        box.x1 = floor(bbox(1));
        box.y1 = floor(bbox(2));
        box.x2 = x1 + floor(bbox(3));
        box.y2 = y1 + floor(bbox(4));
        
        bboxes = [bboxes; box];
    end
    staffCount = size(bboxes,1);
    
    %%%% Generate staff regions based on the bounding boxes %%%%
    % Staff regions are equally divided regions in the image that encloses
    % the staff boxes and meets halfway to the next box. The intention is
    % to use these regions to isolate each staff and notes.
    %%%%
    verticalCuts = ones(1, staffCount+1);
    verticalCuts(end) = size(image, 1);
    for i=2:staffCount
        yPrevious = bboxes(i-1).y2;
        yCurrent = bboxes(i).y1;
        verticalCuts(i) = yPrevious + floor((yCurrent-yPrevious)/2);
    end
    
    % Compute combined outer region of bounding boxes.
    outerRegionLeft  = bboxes(1).x1;
    outerRegionRight = bboxes(1).x2;
    for i=2:staffCount
        outerRegionLeft  = min(outerRegionLeft, bboxes(i).x1);
        outerRegionRight = max(outerRegionRight, bboxes(i).x2);
    end 
    outerRegionWidth = outerRegionRight-outerRegionLeft;
    
    % Extract staff segments
    individualStaffs = [];
    for i=1:staffCount
        % Determine region using width of bounding box and height of vertical cuts
        xBegin = bboxes(i).x1;
        xEnd   = bboxes(i).x2;
        yBegin = verticalCuts(i);
        yEnd   = verticalCuts(i+1);

        % Crop based on the new region
        staff = struct;
        staff.image = image(yBegin:yEnd, xBegin:xEnd);
        staff.mask  = staffsMask(yBegin:yEnd, xBegin:xEnd); 
        
        % Resize width of each staff to match the outer region
        staff.image = imresize(staff.image, [size(staff.image, 1) outerRegionWidth], 'bicubic');
        staff.mask  = imresize(staff.mask,  [size(staff.image, 1) outerRegionWidth], 'nearest');
        
        % New bounding box width is the width of the image segment.
        % New height is the same but has the vertical cut as origin.
        staff.staffBeginY = bboxes(i).y1-yBegin;
        staff.staffEndY = bboxes(i).y2-yBegin;
        
        individualStaffs = [individualStaffs; staff];
    end
end

