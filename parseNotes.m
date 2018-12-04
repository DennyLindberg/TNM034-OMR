function [notes] = parseNotes(staffStruct)
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
            newNote.durationFraction = 4; 
            isEight = false;
            if isEight
                newNote.pitch = lower(newNote.pitch);
                newNote.durationFraction = 8; 
            end        

            notes = [notes; newNote];
        end
    end
end

