function [warpedImage, tform] = imwarpUsingLines(image, fromLines, toLines)
    % Generate points for fitgeotrans
    points = [];
    targetPoints = [];
    for i = 1:length(fromLines)
        points = [points; fromLines(i).origin.x fromLines(i).origin.y];
        points = [points; fromLines(i).end.x fromLines(i).end.y];
        
        targetPoints = [targetPoints; toLines(i).origin.x toLines(i).origin.y];
        targetPoints = [targetPoints; toLines(i).end.x toLines(i).end.y];
    end

    % Perspective correction
    tform = fitgeotrans(points, targetPoints, 'projective');
    warpedImage = 1-imwarp(1-image, tform);
end

