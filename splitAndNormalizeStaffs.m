function [staffSegments] = splitAndNormalizeStaffs(image, staffsInfo, desiredWidth)
    
    % Separate each staff based on vertical cuts.
    % Crop each staff to have the same width as the outer region.
    staffSegments = [];
    staffCount = staffsInfo.count;
    outerRegion = staffsInfo.bboxesRegion;
    for i=1:staffCount
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extract each staff from image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xBegin = staffsInfo.bboxes(i).x1;
        xEnd   = staffsInfo.bboxes(i).x2;
        yBegin = staffsInfo.verticalCuts(i).start;
        yEnd   = staffsInfo.verticalCuts(i).end;
        cropWidthRegion  = xBegin:xEnd;
        cropHeightRegion = yBegin:yEnd;
        
        segment = struct;
        segment.image   = image(cropHeightRegion, cropWidthRegion);
        segment.mask    = staffsInfo.mask(cropHeightRegion, cropWidthRegion);
        segment.bbox    = staffsInfo.bboxes(i);
        segment.bbox.y1 = segment.bbox.y1-yBegin;
        segment.bbox.y2 = segment.bbox.y2-yBegin;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Resize width of each staff to match the outer region
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        segmentHeight = size(segment.image, 1);
        segmentWidth  = outerRegion.x2-outerRegion.x1;
        segment.image = imresize(segment.image, [segmentHeight segmentWidth], 'bicubic');
        segment.mask  = imresize(segment.mask, [segmentHeight segmentWidth], 'nearest');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Resize and straighten out the staff lines by
        % stepping over each pixel column and resizing them.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         targetHeight = segment.bbox.y2-segment.bbox.y1;
%         searchRangeY = segment.bbox.y1:segment.bbox.y2;
%         column_height = size(segment.image, 1);
%         for x=1:segmentWidth
%             % Detect top and bottom corner points of the mask
%             indicesFirst = find(segment.mask(searchRangeY, x), 1, 'first');
%             indicesLast  = find(segment.mask(searchRangeY, x), 1, 'last');
%                
%             % Determine if search was successful and store the positions.
%             % Note that the index is offset by limY1 because the search started there.
%             firstPointY = 1;
%             lastPointY = segmentHeight;
%             if size(indicesFirst) > 0
%                 firstPointY = indicesFirst(1)+segment.bbox.y1;
%             end
%             if size(indicesLast) > 0
%                 lastPointY = indicesLast(1)+segment.bbox.y1;
%             end
% 
%             % Detect if the points are not at the border already
%             % (if they are, there is no point to resize the height)
%             if firstPointY ~= 1 || lastPointY ~= segmentHeight
%                 pointsDistance = (lastPointY-firstPointY);
%                 scaleFactor = targetHeight / pointsDistance; % used for adjusting the coordinates
%                 
%                 % scale image and mask columns
%                 %newColumnHeight = round(scaleFactor*size(segment.image, 1));
%                 
%                 image_column = segment.image(:, x);
%                 image_column = imresize(image_column, scaleFactor, 'nearest');
%                 
%                 mask_column = segment.mask(:, x);
%                 mask_column = imresize(mask_column, scaleFactor, 'nearest');
%                 
%                 % Calculate how much the coordinates got offset
%                 firstPointY_scaled = round(firstPointY*scaleFactor);
%                 lastPointY_scaled = round(lastPointY*scaleFactor);
%                 deltaY = firstPointY_scaled-firstPointY;
%                 
%                 % Use the new coordinates to extract the region to copy
%                 % Move region so that the first point begins in the same spot
%                 newFirstIndex = deltaY;
%                 newLastIndex = deltaY+column_height-1;
%                 newLength = newLastIndex-newFirstIndex;
%                 newRegionY = newFirstIndex:newLastIndex; 
%                 
%                 % Copy the resized region back into the image and mask
%                 segment.image(:, x) = image_column(newRegionY, 1);
%                 segment.mask(:, x) = mask_column(newRegionY, 1);
%                 
%                 clear image_column;
%                 clear mask_column;
%             end
%         end
%         
%         segment.image([segment.bbox.y1, segment.bbox.y2], 1:segmentWidth) = 0;
        
        % After straightening, adjust line lengths individually
        % to get rid of perspective skew.
        
        
        % Recalculate bbox
        % Determine staff begin/end
        % Staff positions
        staffSegments = [staffSegments; segment];
    end
    

end

