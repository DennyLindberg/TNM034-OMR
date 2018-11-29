function [result] = extractLinesByAngle(image, searchAngle, angleStepSize)
    % maxAngleOffset is the +- offset from the horizontal line
    % stepSize is how many degrees to iterate between -maxAngleOffset:stepSize:maxAngleOffset
    
    % Aggressively increase contrast in image (push midtones to extremes)
    lines = histeq(image);
    lines = imadjust(lines, [graythresh(lines) 1.0]);
    lines = imadjust(lines, [0.0 graythresh(lines)]);
    
    % Thicken details to help with line search
    lines = imerode(lines, strel('disk', 1, 4));
    
    % Separate the lines by using structuring elements at different angles
    lineSearchLength = size(lines,2)/4;
    result = ones(size(lines));
    for angle=-searchAngle:angleStepSize:searchAngle      
        result = result .* imclose(lines, strel('line', lineSearchLength, angle));
    end
end

