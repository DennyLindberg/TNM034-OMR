function [notes, staffsInfo] = perspectiveCorrection(image)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perspective correction pass 1
    % - Detect lines in image and straightened them out horizontally
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % First detect feature lines in the image
    [detectedLines, projectedLines] = perspectiveCorrection_HorizontalLinesDetection(image);
    lineCount = size(detectedLines, 1);
    
    % Generate points for fitgeotrans
    points = []; targetPoints = [];
    for i = 1:lineCount
        points = [points; detectedLines(i).origin.x detectedLines(i).origin.y];
        points = [points; detectedLines(i).end.x detectedLines(i).end.y];
        
        targetPoints = [targetPoints; projectedLines(i).origin.x projectedLines(i).origin.y];
        targetPoints = [targetPoints; projectedLines(i).end.x projectedLines(i).end.y];
    end

    % Apply perspective transform
    tform = fitgeotrans(points, targetPoints, 'projective');
    notes = 1-imwarp(1-image, tform);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perspective correction pass 2
    % - When there are multiple staffs, apply a second correction
    %   to ensure that all staffs have near-identical widths.
    %
    % - This is done by extracing corner points from the first and
    %   last staff bounding box.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create blocks around each staff and get properties such as bounding boxes
    staffsInfo = staffLinesToBlocks(notes);
    

    
    
    
    
    
    
    return;
    disp("This message should not appear during execution");
    
        
    
    
    

    
    %%%%%%%%
    % The code below is not executed at the moment.
    % It was an old attempt to make staffs have
    % equal widths.
    %%%%%%%%
    
    % Skip adjustment if there is only one staff
    if staffsInfo.count == 1
        return;
    end
    
    % Start by defining the first and last staff bounding box
    bbox1 = staffsInfo.bboxes(1);
    bbox2 = staffsInfo.bboxes(staffsInfo.count);
    previousBbox = bbox1;
    if staffsInfo.count > 2
        previousBbox = staffsInfo.bboxes(staffsInfo.count-1);
        bbox2 = staffsInfo.bboxes(staffsInfo.count);
    end
    
    % Estimate if the last staff has full length. If it does not, set 
    % the end point to the same length as for the previous staff.
    previousWidth = previousBbox.x2-previousBbox.x1;
    width = bbox2.x2-bbox2.x1;
    if (width/previousWidth) < 0.75
        % Less than 3/4 length of the previous staff => extend the end
        bbox2.x2 = previousBbox.x2;
    end    

    % Now identify the outermost corners of the upper and lower bbox
    % so that we can straighten out the staff widths.
    outerRegion = staffsInfo.bboxesRegion;
    p1 = [bbox2.x1 bbox2.y1];
    p2 = [bbox1.x1 bbox1.y2];
    p3 = [bbox2.x2 bbox2.y1];
    p4 = [bbox1.x2 bbox1.y2];
    points = [p1; p2; p3; p4];
    
    p1 = [outerRegion.x1 bbox2.y1];
    p2 = [outerRegion.x1 bbox1.y2];
    p3 = [outerRegion.x2 bbox2.y1];
    p4 = [outerRegion.x2 bbox1.y2];
    targetPoints = [p1; p2; p3; p4];
    
    % Apply projective transform to straighten out the staffs
    tform = fitgeotrans(points, targetPoints, 'projective');
    notes = 1-imwarp(1-notes, tform);
    
    % Now that the image has been transformed we need to re-run the
    % staffsInfo pass again.
    % (it is too error prone to attempt to fix this by transforming the
    % points)
    staffsInfo = staffLinesToBlocks(notes);
    
    % Crop the image width to the bounds (height is not affected)
    notes = notes(:, staffsInfo.bboxesRegion.x1:staffsInfo.bboxesRegion.x2);
    
    % Recalculate the coordinates of staffsInfo based on the cropped image
    deltaX = staffsInfo.bboxesRegion.x1;
    staffsInfo.bboxesRegion.x1 = 1;
    staffsInfo.bboxesRegion.x2 = size(notes, 2);
    for i=1:staffsInfo.count
        staffsInfo.bboxes(i).x1 = staffsInfo.bboxesRegion.x1;
        staffsInfo.bboxes(i).x2 = staffsInfo.bboxesRegion.x2;
        
        staffsInfo.centroids(i).x = staffsInfo.centroids(i).x-deltaX;
    end
end

