% Attempts to remove background and isolates the notes
function [result] = prepareforsegmentation(image)
    % Version 1 - params (image, botHatDisc = 64, contrast = 0.5)
    %result = imbothat(image,strel('disk', botHatDisc));  % Apply bottom hat filter
    %result = imadjust(result, [0.0, contrast]);          % Increase contrast
    
    % Version 2
    background = imclose(image, strel('Disk',10));
    extractedNotes = imsubtract(background, image);
    result = imadjust(extractedNotes, [0.1, 0.5]);  % these values are arbitrary but seems to work well in most cases
end

