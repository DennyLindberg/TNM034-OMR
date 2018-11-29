function [alpha] = getLinesAlphaByAngle(image, searchAngle, angleStepSize, lineSearchLength)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Optional parameters default values
    % searchAngle: +- offset from the horizontal line
    % angleStepSize: used when creating range min:step:max
    % lineSearchLength: how long the strel('line') should be
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 4; lineSearchLength = size(image,2)/4; end
    if nargin < 3; angleStepSize = 1; end
    if nargin < 2; searchAngle = 10; end
    
    lineSearchLength = round(lineSearchLength);
    
    % Aggressively increase contrast in image (push midtones to extremes)
    lines = histeq(image);
    lines = imadjust(lines, [graythresh(lines) 1.0]);
    lines = imadjust(lines, [0.0 graythresh(lines)]);
    
    % Thicken details to help with line search
    lines = imerode(lines, strel('disk', 1, 4));
    
    % Separate the lines by using structuring elements at different angles
    alpha = ones(size(lines));
    for angle=-searchAngle:angleStepSize:searchAngle     
        alpha = alpha .* imclose(lines, strel('line', lineSearchLength, angle));
    end
    
    % flip alpha so that lines are white
    alpha = 1-alpha;
end

