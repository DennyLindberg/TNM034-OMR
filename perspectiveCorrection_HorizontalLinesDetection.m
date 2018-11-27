function [originalLines, horizontalLines] = perspectiveCorrection_HorizontalLinesDetection(imageGrayscale, imdivider, preprocess)
    if nargin < 2 || imdivider == 0
       imdivider = 8;
    end

    imageBW = [];
    if nargin < 3 || preprocess ~= "nopreprocess"
        imageBW = edge(imageGrayscale, 'sobel', 'nothinning', 'horizontal');
    else
        imageBW = imageGrayscale < graythresh(imageGrayscale);    
    end
    
    [H, T, R] = hough(imageBW, 'Theta', -90:0.1:89.9); % T = Theta, R = Rho
    P = houghpeaks(H, 10);
    
    segmentLength = size(imageGrayscale, 2)/imdivider;
    hglines = houghlines(imageBW, T, R, P,'FillGap',segmentLength/2,'MinLength',segmentLength);
    lineCount = size(hglines, 2);
    
    % todo: detect which side has the largest distance before flattening
    % the image.
    
    originalLines = [];
    for i = 1:lineCount
        xy = [hglines(i).point1; hglines(i).point2];

        line = struct;
        line.origin = struct('x', xy(1,1), 'y', xy(1,2));
        line.end = struct('x', xy(2,1), 'y', xy(2,2));
        line.direction = struct('x', line.end.x-line.origin.x, 'y', line.end.y-line.origin.y);
        line.length = sqrt(line.direction.x^2 + line.direction.y^2);
        line.direction.x = line.direction.x / line.length;
        line.direction.y = line.direction.y / line.length;
        
        line.theta = hglines(i).theta;
        line.rho = hglines(i).rho;
        
        originalLines = [originalLines; line];
    end
    
    % sort lines based on left side y-axis
    [~,I] = sort(arrayfun(@(line) line.origin.y, originalLines)) ;
    originalLines = originalLines(I);
    
    horizontalLines = originalLines;
    for i = 1:lineCount
        line = originalLines(i);
        line.direction.y = 0;
        line.direction.x = 1;
        line.end.y = line.origin.y; % same height
        line.end.x = line.origin.x + line.length;
        line.theta = 90;            % flattened horizontally
        horizontalLines(i) = line;        
    end
end

