function scatterLines = scatterLinesForBlock(blockStruct)      
    % Get data from struct
    imageBW = blockStruct.data < graythresh(blockStruct.data);
    segmentLength = size(imageBW, 2)/2;
    lineXOffset = blockStruct.location(2);
    
    % Run Hough transform to find lines in image
    [H, T, R] = hough(imageBW, 'Theta', -90:0.1:89.9);
    P = houghpeaks(H, 10);
    hglines = houghlines(imageBW, T, R, P,'FillGap',segmentLength/2,'MinLength',segmentLength);
    
    % For
    numLines = size(hglines, 2);
    scatterLines = zeros(numLines, 4);
    for i = 1:numLines
        scatterLines(i, 1) = hglines(i).point1(1)+lineXOffset;
        scatterLines(i, 2) = hglines(i).point1(2);
        scatterLines(i, 3) = hglines(i).point2(1)+lineXOffset;
        scatterLines(i, 4) = hglines(i).point2(2);
    end
    
    % Remove all invalid lines
    scatterLines = scatterLines(scatterLines(:, 1) > 0, :);
end

