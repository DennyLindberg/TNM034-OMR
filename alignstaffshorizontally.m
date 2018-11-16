% This corrects a slightly rotated image. (won't correct perspective
% distortion)
function [alignedResult] = alignstaffshorizontally(image, horizontalAngleThreshold, bitmapThreshold)
    % Default parameter values
    levelThreshold = 0.8;
    angleThreshold = 45;
    if nargin < 2
        bitmapThreshold = bitmapThreshold;
    elseif nargin < 1
        horizontalAngleThreshold = horizontalAngleThreshold;
    end
    
    % Use thresholded image for detecing lines
    imageThreshold = image > levelThreshold;
    
    % Extract lines
    imageEdges = edge(imageThreshold, 'canny');
    [H, T, R] = hough(imageEdges, 'Theta', -90:0.1:89.9); % T = Theta, R = Rho
    P = houghpeaks(H,2);
    lines = houghlines(imageEdges, T, R, P);
    
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

