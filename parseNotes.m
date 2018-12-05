function [notes, debugImage] = parseNotes(staffStruct)
    notes = [];
    staffHeight = max(1, (staffStruct.bottom - staffStruct.top));
    staffImage = staffStruct.image;
    noteRegions = staffStruct.noteRegions;
    regionsCount = staffStruct.noteRegionsCount;
    
    debugImage = zeros(size(staffImage));
    for k=1:regionsCount
        r = noteRegions(k);
        x = r.x;
        y = r.y;
        regionHeight = (y.end-y.start);
        regionWidth = (x.end-x.start);
        regionRatio = regionWidth / regionHeight;
        regionMiddleX = x.start + round(regionWidth/2);
        regionArea = regionWidth*regionHeight;
        [staffPosition, staffFifthLine] = getStaffSplineCoordinates(staffStruct, regionMiddleX);
        staffDistance = staffFifthLine - staffPosition;
        rowStep = staffDistance/4;
        
        imageRegion = staffImage(y.start:y.end, x.start:x.end);
        
        % Remove G-clef by estimating the left limit of the image based
        % on the height of the staff
        if x.start < staffHeight
            continue;
        end
        
        % Remove regions that are not tall enough
        junkCutoffHeight = staffDistance*0.7;
        if regionHeight < junkCutoffHeight
           continue;
        end
        
        % Remove if a region is too small (less than 4 note heads)
        % TODO: Long duration notes without a stem are removed.
        junkCutoffArea = rowStep^2 *4;
        if regionArea < junkCutoffArea; continue; end
        
        % Remove very thin vertical lines
        if regionRatio < 0.25; continue; end 
        
        
        % Beam detection (may have false positives)
       % regionRatio = regionWidth / regionHeight;
        %isPotentialBeam = regionRatio > 0.6;
        %%debugImage(y.start:y.end, x.start:x.end) = mask & isPotentialBeam;
        
        % Create mask
        mask = imsharpen(imageRegion, 'Radius', 10, 'Amount', 30);
        mask = mask < 0.98;
        
        % Use area to determine if it is filled
        % TODO: Are some note heads accidentally removed because of area
        %       or because they are smaller regions?

%         %mask = imopen(mask, strel('disk', 7, 4));
%         filledArea = sum(mask(:) == 1);
%         areaRatio = filledArea / regionArea;
%         %disp(filledArea + " / " + regionArea + " = " + areaRatio);
%         if areaRatio > 0.4
%            % continue;
%         end
        
        
        % Detect if note heads are potentially present at all
        noteHeadSize = rowStep;
        noteHeadMask = imclose(mask, strel('line', round(noteHeadSize*0.2), 0));    % Heal some gaps
        %noteHeadMask = imopen(noteHeadMask, strel('line', round(noteHeadSize*0.75), 0));


        % Note head detection
        
        %disp(noteHeadSize);
        diskSize = round(rowStep/22 * 8);
        %mask = imopen(mask, strel('line', round(noteHeadSize*0.5), 0));
        %mask = imopen(mask, strel('disk', diskSize, 4));
        
        debugImage(y.start:y.end, x.start:x.end) = ~noteHeadMask;
        
%         sobh1 = imfilter(imageRegion, fspecial('sobel'));
%         sobh2 = imfilter(imageRegion, -fspecial('sobel'));
%         mask = (sobh1 > graythresh(sobh1)) | (sobh2 > graythresh(sobh2));
%        % mask = imopen(mask, strel('line', 4, 0));
%        % mask = imclose(mask, strel('disk', 7, 4));
%         debugImage(y.start:y.end, x.start:x.end) = mask & isPotentialBeam;
        %debugImage(y.start:y.end, x.start:x.end) = ~mask;

        props = regionprops(mask, 'Centroid');
        propscount = size(props, 1);
        for m=1:propscount
            centroid = props(m).Centroid;
            cx = centroid(1,1) + x.start;
            cy = centroid(1,2) + y.start;
           
            newNote = struct;
            newNote.x = cx;
            newNote.y = cy;
            newNote.pitch = "G1";
            newNote.duration = 4;

            notes = [notes; newNote];
        end
    end














    return;

    
    
    
    
    
    
    
    %% OLD STUFF NOT WORKING
    image = staffStruct.image;
    height = size(image, 1);
    image(:, 1:round(height/2)) = 1;

    % Make BW and extract notes without staff lines
    noStaffs = removeStaff(image);

    % Use regionprops and bwlabels to identify "potential" notes
    [labels, labelCount] = bwlabel(noStaffs);

    potentialNoteGroup = [];
    notes = [];
    for k=1:labelCount
        potentialNoteGroup = labels;
        potentialNoteGroup(labels ~= k) = 0;
        noteHeads = extractNotes(potentialNoteGroup);

        %Now we can get the position of each note head
        noteProps = regionprops(noteHeads, 'Centroid');
        noteCount = size(noteProps, 1);
        if noteCount == 0
            continue;
        end

        for k=1:size(noteProps, 1)
            c = noteProps(k).Centroid;

            newNote = struct;
            newNote.y = c(1,2);
            newNote.x = c(1,1);
            newNote.pitch = "G1";
            newNote.duration = 4;

            [firstLine, fifthLine] = getStaffSplineCoordinates(staffStruct, newNote.x);
            localStaffHeight = fifthLine-firstLine;
            pitchStep = localStaffHeight/8;
            hysteresis = pitchStep/2;
            newNote.offset = newNote.y+hysteresis-firstLine;
            pitch = floor((newNote.y-firstLine+hysteresis) / pitchStep); 

            % F3 is the top line
            fourths = ["G1", "A1", "B1", "C2", "D2", "E2", "F2", "G2", "A2", "B2", "C3", "D3", "E3", "F3", "G3", "A3", "B3", "C4", "D4", "E4"];
            indexOffset = 14;
            maxIndex = size(fourths, 2);
            pitch = min(maxIndex, max(1, -pitch+indexOffset));
            newNote.pitch = fourths(pitch);
            isEight = false;
            if isEight
                newNote.pitch = lower(newNote.pitch);
                newNote.duration = 8; 
            end        

            notes = [notes; newNote];
        end
    end
end

