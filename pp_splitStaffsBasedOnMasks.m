function [individualStaffs, staffCount] = pp_splitStaffsBasedOnMasks(image, staffsMask, notesMask)  
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
    notesProps = regionprops(notesMask, 'BoundingBox');
    staffCount = size(notesProps, 1);
    if staffCount == 0; return; end
    
    % Sort props based on bounding box vertical order
    if staffCount > 0
        bboxes = cat(1, notesProps.BoundingBox);
        [sorted, sort_order] = sort(bboxes(:, 2));
        notesProps = notesProps(sort_order);
    end
    
    % Generate list of boxes for easier processing
    limits = [];
    for i=1:staffCount   
        bbox = notesProps(i).BoundingBox;
        x1 = floor(bbox(1));
        y1 = floor(bbox(2));
        x2 = x1 + floor(bbox(3));
        y2 = y1 + floor(bbox(4));
        
        % Remove bad staffs
        cx = round((x1+x2)/2);
        cy = round((y1+y2)/2);
        limitX = imageWidth*0.02;
        limitY = imageHeight*0.02;
        if cx < limitX || cx > (imageWidth-limitX) || ...
           cy < limitY || cy > (imageHeight-limitY)
           %disp("Removed bad staff, the midpoint was too close to the image border");
           continue;
        end
        
        % Extract current staff mask and calculate the bbox of it
        staffY1 = y1;
        staffY2 = y2;
        localMask = zeros(size(notesMask));
        localMask(y1:y2, x1:x2) = 1;
        localMask = and(localMask, staffsMask);
        staffProps = regionprops(localMask, 'BoundingBox');
        if ~isempty(staffProps)
            firstProperty = staffProps(1);
            staffY1 = floor(firstProperty.BoundingBox(2));
            staffY2 = staffY1 + floor(firstProperty.BoundingBox(4));
        end
        
        newLimit = struct;
        newLimit.x1 = floor(bbox(1));
        newLimit.y1 = floor(bbox(2));
        newLimit.x2 = x1 + floor(bbox(3));
        newLimit.y2 = y1 + floor(bbox(4));
        newLimit.staffY1 = staffY1;
        newLimit.staffY2 = staffY2;
        
        limits = [limits; newLimit];
    end
    staffCount = size(limits,1);
    
    % Extract staff segments
    individualStaffs = [];
    for i=1:staffCount
        yBegin = limits(i).y1;
        yEnd   = limits(i).y2;
        xBegin = limits(i).x1;
        xEnd   = limits(i).x2;
        
        if i==staffCount && i > 1
            % Don't crop the last staff if it is much shorter
            % than the previous staff.
            scale = (xEnd-xBegin)/(limits(i-1).x2-limits(i-1).x1);
            if scale < 0.95
                xEnd = xBegin + (limits(i-1).x2-limits(i-1).x1);
            end
        end

        % Crop based on the new region
        staff = struct;
        staff.image = image(yBegin:yEnd, xBegin:xEnd);
        staff.staffMask = staffsMask(yBegin:yEnd, xBegin:xEnd); 
        staff.notesMask = notesMask(yBegin:yEnd, xBegin:xEnd); 
        
        % New bounding box width is the width of the image segment.
        % New height is the same but has the vertical cut as origin.
        staff.top = max(1, limits(i).staffY1-yBegin);
        staff.bottom = max(1, limits(i).staffY2-yBegin);
        
        % To be generated
        staff.topSpline = [];
        staff.bottomSpline = [];
        
        individualStaffs = [individualStaffs; staff];
    end
end

