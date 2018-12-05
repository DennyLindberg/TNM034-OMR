% Attempts to isolate notes from the background
function [notes, notesRegion] = pp_removeBackground(image)
    image = imgaussfilt(image);

    % Separate background and notes by using morphological operations
    imageSize = size(image);
    diskSize = floor(imageSize(1,2)/100);               
    background = imclose(image, strel('Disk', diskSize)); % close gaps/dark regions = remove notes = keep background
    notes = imsubtract(background, image);                % subtract the image WITH notes from background = keep notes (notes are close to 0 and thus not subtracted)
    notes = min(1, max(0, notes));
    
    % Create a convex hull mask around the notes
    thresh = 0.08;                                        % value chosen based on manual testing
    notesBW = edge(notes, 'sobel', thresh, 'horizontal'); % use horizontal edges to determine the edge of the hull
    hullMask = bwconvhull(notesBW);
    
    % Erase everything outside the hull mask to remove remaining background
    % noise.
    notes(~hullMask) = 1.0;
    notes(hullMask) = 1.0-notes(hullMask);

    % Use the hull mask to improve the contrast around the notes and erase
    % the fragments of the background
    lowerThresh = graythresh(notes)*0.1;
    upperThresh = 1-lowerThresh;                          % value chosen based on manual testing
    notes = imadjust(notes, [lowerThresh, upperThresh]);  % increase contrast and push weak noise to the limits    

    % Determine region of notes
    bbox = [1, 1, size(image,2), size(image,1)];
    props = regionprops(hullMask, 'BoundingBox');
    if size(props,1) > 0
        bbox = props(1).BoundingBox;
    end
    startX = max(1,bbox(1));
    endX = min(size(image,2), bbox(1)+bbox(3));
    startY = max(1, bbox(2));
    endY = min(size(image,1), bbox(2)+bbox(4));
    notesRegion = round([startX, startY, endX, endY]);
end

