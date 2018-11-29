function [staffsSegments] = extractStaffsSegments(image)  
    % Aggressively increase contrast in image (push midtones to extremes)
    lines = histeq(image);
    lines = imadjust(lines, [graythresh(lines) 1.0]);
    lines = imadjust(lines, [0.0 graythresh(lines)]);
    
    % Separate the lines
    segmentLength = size(lines,2)/4;
    lines = imerode(lines, strel('disk', 2, 4));
    lines = imdilate(lines, strel('line', segmentLength, 0));
    lines = imerode(lines, strel('line', segmentLength, 0));
    
    % Melt lines together to create a "block" for each group of staff lines
    lines = imerode(lines, strel('disk', 16, 4));
    lines = imdilate(lines, strel('disk', 16, 4));
    
    % Use region props to detect the bounding box of the staff "blocks"
    staffsMask = lines < graythresh(lines);
    props = regionprops(staffsMask, 'BoundingBox');
    staffCount = size(props, 1);
    
    if staffCount == 0
        % No staffs found, exit early
        staffsSegments = [];
        return;
    end
    
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
        
        box = struct;
        box.x1 = floor(bbox(1));
        box.y1 = floor(bbox(2));
        box.x2 = x1 + floor(bbox(3));
        box.y2 = y1 + floor(bbox(4));
        
        bboxes = [bboxes; box];
    end
    
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
    staffsSegments = [];
    for i=1:staffCount
        % Determine region using width of bounding box and height of vertical cuts
        xBegin = bboxes(i).x1;
        xEnd   = bboxes(i).x2;
        yBegin = verticalCuts(i);
        yEnd   = verticalCuts(i+1);

        % Crop based on the new region
        segment = struct;
        segment.image = image(yBegin:yEnd, xBegin:xEnd);
        segment.mask  = staffsMask(yBegin:yEnd, xBegin:xEnd); 
        
        % Resize width of each staff to match the outer region
        segment.image = imresize(segment.image, [size(segment.image, 1) outerRegionWidth], 'bicubic');
        segment.mask  = imresize(segment.mask,  [size(segment.image, 1) outerRegionWidth], 'nearest');
        
        % New bounding box width is the width of the image segment.
        % New height is the same but has the vertical cut as origin.
        segment.staffBeginY = bboxes(i).y1-yBegin;
        segment.staffEndY = bboxes(i).y2-yBegin;
        
        % DRAW DEBUG
        if false
            segment.image = 1-(1-segment.image)*0.2;
            segment.image(segment.staffBeginY, :) = 0;
            segment.image(segment.staffEndY, :) = 0;
        end
        
        staffsSegments = [staffsSegments; segment];
    end
end

