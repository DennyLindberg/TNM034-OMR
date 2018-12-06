function [notes, debugImage] = parseNotes(staffStruct)
    notes = [];
    staffHeight = max(1, (staffStruct.bottom - staffStruct.top));
    staffImage = removeStaff(staffStruct.image);

    noteRegions = staffStruct.noteRegions;
    regionsCount = staffStruct.noteRegionsCount;
    
    % Create a second image which greatly simplifies extracting the
    % note heads and beams.  
    beamsAndHeads = 1-staffStruct.image;
    beamsAndHeads = ordfilt2(beamsAndHeads,35,true(10)); % flatten noise (bit blurry)
    beamsAndHeads = 1-imextendedmin(beamsAndHeads, graythresh(beamsAndHeads));
    beamsAndHeads = imdilate(beamsAndHeads, strel('disk', 1, 4)); % connect nearby components
    
    
    % Mask contains all strong shapes
    mask = imsharpen(staffImage, 'Radius', 10, 'Amount', 30);
    mask = mask < 0.98;
    
    debugImage = zeros(size(staffImage));
    noteHeads = [];
    for k=1:regionsCount
        r = noteRegions(k);
        x = r.x;
        y = r.y;        
        
        % Remove G-clef or numbers behind it by estimating the left limit 
        % of the image based on the height of the staff
        if staffStruct.id == 1 && x.start < staffHeight*1.5 || staffStruct.id ~= 1 && x.start < staffHeight
            continue;
        end
        
        % Precalculate reference values
        regionHeight = (y.end-y.start);
        regionWidth = (x.end-x.start);
        regionRatio = regionWidth / regionHeight;
        regionMiddleX = x.start + round(regionWidth/2);
        regionArea = regionWidth*regionHeight;
        [staffPosition, staffFifthLine] = getStaffSplineCoordinates(staffStruct, regionMiddleX);
        staffDistance = staffFifthLine - staffPosition;
        rowStep = staffDistance/4;
        noteHeadHeight = rowStep;
        
        if regionWidth < noteHeadHeight
            continue; % Throw away very thin regions
        end
        
        % Use ratio of region to determine if it 'could'
        % be multiple notes in a row.
        potentialBeam = regionRatio > 0.6;
        if potentialBeam && regionWidth < noteHeadHeight*2
            % TODO: Could be a long duration note
            continue; % throw away almost square but small regions.
        end

        % Extract region of interest
        imageRegion = staffImage(y.start:y.end, x.start:x.end);
        maskRegion = mask(y.start:y.end, x.start:x.end);
        
        % Detect if there is a stem (vertical line) in the region.
        % (line and tall enough = is a stem)
        hasStem = false;
        stemMask = imopen(maskRegion, strel('line', round(regionHeight/2), 90));
        stemMask = imdilate(stemMask, strel('disk', 1, 4));
        stemProps = regionprops(stemMask, 'BoundingBox');
        for m=1:size(stemProps, 1)
            bbox = stemProps(m).BoundingBox;
            if bbox(4) > noteHeadHeight*2
                hasStem = true;
                break;
            end
        end
        
        % Test if there is anything anything left after the stem is removed 
        % for potential single notes.
        maskNoStem = maskRegion & ~stemMask;   
        maskNoStem = imopen(maskNoStem, strel('disk', 2, 4)); % clean up residues
        if sum(maskNoStem(:)) == 0
            continue; % Only black pixels, mask is empty. Can't be a note as it only had a stem.
            
        elseif hasStem && ~potentialBeam
            % SINGLE NOTE CANDIDATES
            
            % Generate a new region around the mask with no stems.
            % This leaves potential note heads remaining.
            noStemProps = regionprops( maskNoStem, 'BoundingBox' );
            xmin = regionWidth; ymin = regionHeight;
            xmax = 1; ymax = 1;
            for m=1:size(noStemProps, 1)
                xmin = min(xmin, noStemProps(m).BoundingBox(1));
                ymin = min(ymin, noStemProps(m).BoundingBox(2));
                xmax = max(xmax, noStemProps(m).BoundingBox(1)+noStemProps(m).BoundingBox(3));
                ymax = max(ymax, noStemProps(m).BoundingBox(2)+noStemProps(m).BoundingBox(4));
            end
            propHeight = ymax-ymin;
            propWidth = xmax-xmin;
            if propHeight < noteHeadHeight*0.5 || propWidth < noteHeadHeight*0.75
               continue; % candidate eliminated, it did not have the proper dimensions for a note head
            end
            
            
            % Two scenarios remain.
            isQuarterNote = true;
            xR = floor(max(1, xmin:xmax));
            yR = floor(max(1, ymin:ymax));
            beamsAndHeadsRegion = beamsAndHeads(y.start:y.end, x.start:x.end);
            beamsAndHeadsRegion = bwareaopen(beamsAndHeadsRegion, staffHeight); % remove small objects
            subRegionBeamsAndHeads = beamsAndHeadsRegion(yR, xR);
            heightFactor = propHeight / propWidth;
            if heightFactor > 2
                % Tall shape. Detect if a head is present.
                subRegionBeamsAndHeads = imopen(subRegionBeamsAndHeads, strel('disk', round(noteHeadHeight/3), 4));
                if sum(subRegionBeamsAndHeads(:)) == 0
                    continue; % no large shapes, not a note
                else
                    isQuarterNote = false;
                end
            end
                
                
            % Default centroid for each note head based on bounding box.
            % This position is used for shapes like open notes which does
            % not have a dominant shape to be detected.
            cx = xmin + floor(propWidth/2);
            cy = ymin + floor(propHeight/2);
            
            % Attempt to get the proper center by using shape. This works
            % well for filled notes.
            beamsAndHeadsRegion = imclose(beamsAndHeadsRegion, strel('disk', round(noteHeadHeight), 4));
            beamsAndHeadsRegion = imopen(beamsAndHeadsRegion, strel('disk', round(noteHeadHeight/3), 4));     
            headProps = regionprops(beamsAndHeadsRegion, 'Centroid', 'Area', 'Orientation');
            greatestArea = 0;
            
            orientation = 0;
            for m=1:size(headProps, 1)
                c = headProps(m).Centroid;
                a = headProps(m).Area;
                
                if a > greatestArea
                    orientation = abs(headProps(m).Orientation); 

                    greatestArea = a;
                    cx = c(1,1);
                    cy = c(1,2);
                end
            end
            
            % eliminate vertically oriented props. The heads are typically
            % around 30-60 degrees.
            if orientation < 80 
                if isQuarterNote
                    noteHeads = [noteHeads; struct('x', cx + x.start, 'y', cy + y.start, 'duration', 4)];
                else
                    noteHeads = [noteHeads; struct('x', cx + x.start, 'y', cy + y.start, 'duration', 8)];
                end
                
                debugImage(y.start:y.end, x.start:x.end) = beamsAndHeadsRegion;
            end
        elseif potentialBeam
            % There are some notes that stick together and are not beams,
            % so we need to detect those.
            
            beamsAndHeadsRegion = beamsAndHeads(y.start:y.end, x.start:x.end);
            beamsAndHeadsRegion = bwareaopen(beamsAndHeadsRegion, round((noteHeadHeight^2)/4)); % remove small objects                 
            
            hasBeam = false;
            headProps = [];
            noteProps = regionprops(beamsAndHeadsRegion, 'BoundingBox', 'Centroid', 'Eccentricity', 'Orientation');
            % Eccentricity is used to check roundness of shapes.
            % Orientation to exclude horizontal beams.
            % Centroid for final location.
            % Bounding box for width (thus a beam)
            
            % Look for beam
            for m=1:size(noteProps, 1)
                bbox = noteProps(m).BoundingBox;
                width = round(bbox(3));
                if width > rowStep*1.75
                   % Determine midpoint and filter the others so that
                   % other beams are not miss-registered.
                   hasBeam = true; 
                else
                   headProps = [headProps; noteProps(m)];
                end
            end
            
            if hasBeam
                for m=1:size(headProps, 1)
                    c = headProps(m).Centroid;
                    if abs(headProps(m).Orientation) > 3 && headProps(m).Eccentricity < 0.95
                        noteHeads = [noteHeads; struct('x', c(1,1) + x.start, 'y', c(1,2) + y.start, 'duration', 8)];
                    end
                end
            else
                % We could have "single notes" that overlap.
                % Clean up shapes and look for note heads.
                beamsAndHeadsRegion = imopen(beamsAndHeadsRegion, strel('disk', round(noteHeadHeight/3), 4));  
                noteProps = regionprops(beamsAndHeadsRegion, 'Centroid');
                for m=1:size(noteProps, 1)
                	c = noteProps(m).Centroid;
                    noteHeads = [noteHeads; struct('x', c(1,1) + x.start, 'y', c(1,2) + y.start, 'duration', 4)];
                end
            end
            
            debugImage(y.start:y.end, x.start:x.end) = beamsAndHeadsRegion;
        end
    end
    
    headCount = size(noteHeads, 1);
    for m=1:headCount
        newNote = struct;
        newNote.x = noteHeads(m).x;
        newNote.y = noteHeads(m).y;
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

