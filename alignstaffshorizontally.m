% This corrects a slightly rotated image. (won't correct perspective
% distortion)

% TODO: 
%   houghpeaks currently have 10 max lines, can this be set automatic?
%   houghlines has FillGap and MinLength as arbitrary values. Automate how?

function [alignedResult] = alignstaffshorizontally(image, horizontalAngleThreshold, bitmapThreshold)
    % Default parameter values
    levelThreshold = 0.8;
    angleThreshold = 45;
    if nargin < 2
        bitmapThreshold = bitmapThreshold;
    elseif nargin < 1
        horizontalAngleThreshold = horizontalAngleThreshold;
    end
    
    % Extract lines
    imageBW = image < graythresh(image);
    [H, T, R] = hough(imageBW, 'Theta', -90:0.1:89.9); % T = Theta, R = Rho
    P = houghpeaks(H, 10);
    lines = houghlines(imageBW, T, R, P, 'FillGap', 200, 'MinLength', 50);
    
    % Calculate the average angle of the lines
    Tavg = 0;
    for i = 1:length(lines)
        if abs(lines(i).theta) > angleThreshold
            Tavg = Tavg + lines(i).theta;
        end
    end
    Tavg = Tavg / length(lines);
    
    % Change so that angle is based on the horizontal (0 instead of +-90)
    horizontalOffset = 90 - abs(Tavg);
    horizontalOffset = horizontalOffset * sign(Tavg);
    
    % Rotate the image (invert black/white so that we get a white
    % background crop)
    image = 1-image;
    alignedResult = 1 - imrotate(image, -horizontalOffset, 'bicubic', 'crop');
end

