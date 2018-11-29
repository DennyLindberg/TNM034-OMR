function [normalizedSegments] = splitAndNormalizeStaffs(staffsSegments, blockWidth)
    staffCount = size(staffsSegments, 1);
    for i=1:staffCount
        segment = staffsSegments(i);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Resize and straighten out the staff lines by
        % stepping over each pixel column and resizing them.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        searchRangeY = segment.staffBeginY:segment.staffEndY;
        staffWidth = size(segment.image, 2);
        
        edgePoints = zeros(staffWidth, 2);
        blockCount = ceil(staffWidth/blockWidth);
        segment.image = segment.image*0;
        for x=1:blockCount
            blockBeginX = blockWidth*(x-1)+1;
            blockEndX = min(staffWidth, blockBeginX+blockWidth);
            
            % Debug
            %disp("1 <= (" + blockBegin + ":" + blockEnd + ") <= " + staffWidth);
            
            % Detect top and bottom corner points of the mask
            topIndex = find(segment.mask(searchRangeY, blockBeginX), 1, 'first');
            bottomIndex  = find(segment.mask(searchRangeY, blockBeginX), 1, 'last');
            
            % Determine if search was successful and store the positions.
            % Note that the index is offset by staffBeginY because the search started there.
            topPoint = min(segment.staffEndY, max([segment.staffBeginY, topIndex(:)]));
            bottomPoint = max(segment.staffBeginY, min([segment.staffEndY, bottomIndex(:)]));
            
            segment.image(topPoint, blockBeginX) = 1;
            segment.image(bottomPoint, blockBeginX) = 1;
        end
       
        staffsSegments(i) = segment;
        
       % segmentImage([segment.bbox.y1, segment.bbox.y2], 1:newWidth) = 0;
        
        % After straightening, adjust line lengths individually
        % to get rid of perspective skew.
        
        
        % Recalculate bbox
        % Determine staff begin/end
        % Staff positions
    end
    
    normalizedSegments = staffsSegments;
end

