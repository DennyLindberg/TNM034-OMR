% Attempts to isolate notes from the background
function [result, extractedNotes, background, hullMask] = extractnotesfromphoto(image)
    % Separate background and notes by using morphological operations
    background = imclose(image, strel('Disk',10));
    extractedNotes = imsubtract(background, image);
    
    % Create a convex hull mask around the notes
    decentThreshold = graythresh(extractedNotes);
    notesBW = extractedNotes < decentThreshold;
    hullMask = bwconvhull(1-notesBW);

    % Use the hull mask to improve the contrast around the notes and erase
    % the fragments of the background
    result = ones(size(image));
    result(hullMask) = 1.0-imadjust(extractedNotes(hullMask), [0.05, 0.5]);
end

