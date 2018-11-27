% Attempts to isolate notes from the background
function [notes, background, hullMask, notesBW] = extractnotesfromphoto(image)
    % Separate background and notes by using morphological operations
    diskSize = floor(min(size(image))/100);               % Set disk size to 1% of smallest image dimension
    background = imclose(image, strel('Disk',diskSize));  % close gaps/dark regions = remove notes = keep background
    notes = imsubtract(background, image);                % subtract the image WITH notes from background = keep notes (notes are close to 0 and thus not subtracted)
    
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
    lowerThresh = graythresh(notes);
    upperThresh = 1.0-lowerThresh*0.07;                   % value chosen based on manual testing
    notes = imadjust(notes, [lowerThresh, upperThresh]);  % increase contrast and push weak noise to the limits
end

