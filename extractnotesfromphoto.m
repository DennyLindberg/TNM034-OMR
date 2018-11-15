% Attempts to isolate notes from the background
function [result] = extractnotesfromphoto(image)
    background = imclose(image, strel('Disk',10));
    extractedNotes = imsubtract(background, image);
    result = 1.0-imadjust(extractedNotes, [0.1, 0.5]);  % these values are arbitrary (push midtones further towards darks and lights, increasing contrast)
end

