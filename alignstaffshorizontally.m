% This corrects a slightly rotated image. (won't correct perspective
% distortion)
function [alignedResult] = alignstaffshorizontally(image, bitmapThreshold)
    imageThreshold = image > bitmapThreshold;
    
    % Extract lines
    imageEdges = edge(imageThreshold, 'canny');
    [H, T, R] = hough(imageEdges, 'Theta', -90:0.1:89.9); % T = Theta, R = Rho
    P = houghpeaks(H,2);
    lines = houghlines(imageEdges, T, R, P);
    
    % Calculate the average angle of the lines
    Tavg = 0;
    for i = 1:length(lines)
        Tavg = Tavg + lines(i).theta;
    end
    Tavg = Tavg / length(lines);
    
    % Change so that angle is based on the horizontal (0 instead of +-90)
    horizontalOffset = 90 - abs(Tavg);
    horizontalOffset = horizontalOffset * sign(Tavg);
    
    % Rotate the image
    alignedResult = imrotate(image, -horizontalOffset, 'bicubic', 'crop');
end

