function [noteRegions, noteRegionsCount] = separateNotesUsingProjections(staffImage)
    height = size(staffImage, 1);

    % Abuse imsharpen so that dark and white regions separate.
    % Create mask from it.
    maskForProjection = imsharpen(staffImage, 'Radius', 10, 'Amount', 30);
    maskForProjection = maskForProjection < 0.98;

    % Remove scrap details
    maskForProjection = bwareaopen(maskForProjection, round(height/2));
    maskForProjection = imdilate(maskForProjection, strel('disk', 1, 4));

    % Small object removal for testing
   % maskForProjection = bwareaopen(maskForProjection, height*15);

    noteRegions = [];
    noteRegionsCount = 0;

    % V PROJECTION
    vSum = sum(maskForProjection, 1);
    vSum = vSum > 0;
    [labels, labelCount] = bwlabel(vSum);
    regions = regionprops(labels, 'BoundingBox');
    for k=1:labelCount
        bbox = regions(k).BoundingBox;
        xRangeStart = max(1, floor(bbox(1)));
        xRangeEnd = max(1, floor(bbox(1)+bbox(3)));    

        hSum = sum(maskForProjection(:, xRangeStart:xRangeEnd), 2);
        hSum = hSum > 0;
        [subLabels, subLabelCount] = bwlabel(hSum);
        subRegions = regionprops(subLabels, 'BoundingBox');
        for m=1:subLabelCount
            subbbox = subRegions(m).BoundingBox;
            yRangeStart = max(1, floor(subbbox(2)));
            yRangeEnd = max(1, floor(subbbox(2)+subbbox(4)));

            newRegion = struct;
            newRegion.x = struct('start', xRangeStart, 'end', xRangeEnd);
            newRegion.y = struct('start', yRangeStart, 'end', yRangeEnd);
            noteRegions = [noteRegions; newRegion];
        end
    end
    noteRegionsCount = size(noteRegions, 1);
end

