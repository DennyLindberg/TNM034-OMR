% Makes notes white (background black) and improves the contrast.
% Bottom hat filter does some cleanup.
% Good defaults are botHadDisc = 64, contrast = 0.5
function [result] = prepareforsegmentation(image, botHatDisc, contrast)
    result = imbothat(image,strel('disk', botHatDisc));  % Apply bottom hat filter
    result = imadjust(result, [0.0, contrast]);          % Increase contrast
end

