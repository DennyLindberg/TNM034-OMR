function [staffsInfo] = staffLinesToBlocks(image)
    staffsInfo = struct;
    staffsInfo.mask = 0;
    staffsInfo.labels = [];
    staffsInfo.count = 0;
    staffsInfo.centroids = [];
    staffsInfo.bboxes = [];
    staffsInfo.bboxesRegion = struct; % this region encloses all of the boxes
    staffsInfo.verticalCuts = [];
    
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
    
    % Create a binary mask for 
    staffsInfo.mask = lines < graythresh(lines);
    [staffsInfo.labels staffsInfo.count] = bwlabel(staffsInfo.mask);
    staffCount = staffsInfo.count;
    
    % Use region props to detect the bounding box of the staff "blocks"
    props = regionprops(staffsInfo.mask, 'BoundingBox', 'Centroid');
    
    % Sort props based on bounding box vertical order
    boxes = cat(1, props.BoundingBox);
    if staffCount > 0
        top_edge = boxes(:,2);
        [sorted, sort_order] = sort(top_edge);
        props = props(sort_order);
    end
    
    % Store centroids of new order
    c = cat(1, props.Centroid);
    for i=1:staffCount
       centroid = struct;
       centroid.x = c(i,2);
       centroid.y = c(i,1);
       staffsInfo.centroids = [staffsInfo.centroids; centroid];
    end
    
    % Re-assign labels
    oldLabels = staffsInfo.labels;
    for i=1:staffCount
        staffsInfo.labels(oldLabels == i) = sort_order(i);
    end
    
    % Generate list of boxes for easier processing
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
        
        staffsInfo.bboxes = [staffsInfo.bboxes; box];
    end
    
    %%%% Generate staff regions based on the bounding boxes %%%%
    % Staff regions are equally divided regions in the image that encloses
    % the staff boxes and meets halfway to the next box. The intention is
    % to use these regions to isolate each staff and notes.
    %%%%
    previousEnd = 1;      % top edge
    for i=2:(staffCount+1) % begin with the second box so that we can compare with the previous one
        cut = struct;
        cut.start = previousEnd;

        if i<=staffCount
            yPrevious = staffsInfo.bboxes(i-1).y2;
            yCurrent = staffsInfo.bboxes(i).y1;
            cut.end = yPrevious + floor((yCurrent-yPrevious)/2);
        else
            cut.end = size(image, 1);
        end
        previousEnd = cut.end;
        
        staffsInfo.verticalCuts = [staffsInfo.verticalCuts; cut];
    end
    
    % Also store the enclosing region of all staffs.
    % This can, for example, be used to crop the image or resize each region 
    % to have the same width.
    % If there are no boxes, enclose the whole image.
    minX = 0;
    minY = 0;
    maxX = size(image, 2);
    maxY = size(image, 1);
    
    if staffCount > 0
        minX = staffsInfo.bboxes(1).x1;
        minY = staffsInfo.bboxes(1).y1;
        maxX = staffsInfo.bboxes(1).x2;
        maxY = staffsInfo.bboxes(1).y2;
        for i=2:staffCount
            minX = min(minX, staffsInfo.bboxes(i).x1);
            minY = min(minY, staffsInfo.bboxes(i).y1);
            maxX = max(maxX, staffsInfo.bboxes(i).x2);
            maxY = max(maxY, staffsInfo.bboxes(i).y2);
        end
    end
    
    staffsInfo.bboxesRegion.x1 = minX;
    staffsInfo.bboxesRegion.y1 = minY;
    staffsInfo.bboxesRegion.x2 = maxX;
    staffsInfo.bboxesRegion.y2 = maxY;
end

