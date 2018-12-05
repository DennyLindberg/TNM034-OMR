function [notes, debugImage] = parseNotes(staffStruct)
    notes = [];
    staffHeight = max(1, (staffStruct.bottom - staffStruct.top));
    staffImage = removeStaff(staffStruct.image);

    noteRegions = staffStruct.noteRegions;
    regionsCount = staffStruct.noteRegionsCount;
    
    % Create a second image which greatly simplifies extracting the
    % note heads and beams.  
%     beamsAndHeads = 1-staffStruct.image;
%     beamsAndHeads = ordfilt2(beamsAndHeads,30,true(10)); % flatten noise (bit blurry)
%     beamsAndHeads = 1-imextendedmin(beamsAndHeads, graythresh(beamsAndHeads));
%     beamsAndHeads = imdilate(beamsAndHeads, strel('disk', 1, 4)); % connect nearby components
%     beamsAndHeads = bwareaopen(beamsAndHeads, staffHeight); % remove small objects
    
    debugImage = zeros(size(staffImage));
    for k=1:regionsCount
        noteHeads = [];
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
        

        % Create mask
        mask = imsharpen(imageRegion, 'Radius', 10, 'Amount', 30);
        mask = mask < 0.98;
        
        % Beam detection (may have false positives)
        regionRatio = regionWidth / regionHeight;
        isProbablyASingleNote = regionRatio < 0.6;
        
        noteProps = [];
        notePropsCount = 0;
        if isProbablyASingleNote            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Very likely a single note.
            % There could however be some false
            % shapes.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            noteHeadHeight = rowStep;

            % Vertical mask (removes lines and some false positives (vertical beams))
            vmask = imopen(mask, strel('line', round(regionHeight/2), 90));
            vmask = imerode(vmask, strel('line', round(noteHeadHeight*0.75), 90));
            vmask = imdilate(vmask, strel('disk', 1, 4));
            mask = mask & ~vmask;
            
            % Detect if a stem is present
            % TODO: Find a much better method
            stemProps = regionprops(vmask, 'MajorAxisLength');
            propsCount = size(stemProps, 1);
            if propsCount == 0
               continue;        % no stem, throw away
            else
                hasStem = false;
                for m=1:propsCount
                    if stemProps(m).MajorAxisLength > rowStep
                        hasStem = true;
                        break;
                    end
                end
                if ~hasStem
                    continue;
                end
            end
            
            % Cleanup some residue
            mask = imopen(mask, strel('disk', 2, 4));
            
            % 90% detection of single notes. (some open notes disappear)
            diskSize = round(rowStep/40 * 16); % Dependent on a good balance here
            mask = imclose(mask, strel('disk', diskSize, 4));
            mask = imopen(mask, strel('disk', diskSize, 4));
            
        
            %mask = beamsAndHeads(y.start:y.end, x.start:x.end);
            debugImage(y.start:y.end, x.start:x.end) = mask;

            noteProps = regionprops(mask, 'Centroid');
            notePropsCount = size(noteProps, 1);
            for m=1:notePropsCount
                c = noteProps(m).Centroid;
                noteHeads = [noteHeads; struct("x", c(1,1), "y", c(1,2), "duration", 4)];
            end
        else
            % Local pass
            noteHeadHeight = rowStep;
            beamsAndHeads = 1-staffStruct.image(y.start:y.end, x.start:x.end);
            beamsAndHeads = ordfilt2(beamsAndHeads,30,true(10)); % flatten noise (bit blurry)
            beamsAndHeads = 1-imextendedmin(beamsAndHeads, graythresh(beamsAndHeads));
            beamsAndHeads = imdilate(beamsAndHeads, strel('disk', 1, 4)); % connect nearby components
            beamsAndHeads = bwareaopen(beamsAndHeads, round((noteHeadHeight^2)/2)); % remove small objects
            
            [labels, labelCount] = bwlabel(beamsAndHeads);
            noteProps = regionprops(beamsAndHeads, 'BoundingBox', 'Centroid');
            notePropsCount = size(noteProps, 1);
            
            hasBeam = false;
            filteredProps = [];
            for m=1:notePropsCount
                bbox = noteProps(m).BoundingBox;
                width = round(bbox(3));
                if width > rowStep*1.75
                   hasBeam = true; 
                else
                   filteredProps = [filteredProps; noteProps(m)];
                end
            end
            notePropsCount = size(filteredProps, 1);
            for m=1:notePropsCount
                c = filteredProps(m).Centroid;
                duration = 4;
                if hasBeam; duration = 8; end
                noteHeads = [noteHeads; struct("x", c(1,1), "y", c(1,2), "duration", duration)];
            end
            debugImage(y.start:y.end, x.start:x.end) = beamsAndHeads;
        end
        
        
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
        
        headCount = size(noteHeads, 1);
        for m=1:headCount
            newNote = struct;
            newNote.x = noteHeads(m).x + x.start;
            newNote.y = noteHeads(m).y + y.start;
            newNote.pitch = "G1";
            newNote.duration = noteHeads(m).duration;

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
            if newNote.duration ~= 4
                newNote.pitch = lower(newNote.pitch);
            end        

            notes = [notes; newNote];
        end
    end
end

