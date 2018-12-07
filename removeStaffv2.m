function [imageresult] = betterMask(image)
    imagef = 1-imclose(image, strel('line', 8, 90)); % scale based on image
    imagef = 1-imextendedmin(imagef, graythresh(imagef));
    
    % H LINES ONLY (without affecting features)
    imageh = imclose(image, strel('line', 30, 0));
    imageh = imerode(imageh, strel('line', 2, 90));
    imageh = 1-((1-imagef) .* (1-imageh));
    imageh = histeq(imageh);

    % Remove H lines and emphasize shapes
    imagep = 1-(imageh .* (1-image));
    imagep(imagep > 0.95) = 1;
    imagep = 1-imbinarize(histeq(imagep), 'global');
    imagep = imclose(imagep, strel('disk', 3, 4));
    imagep = imopen(imagep, strel('line', 1, 90));
    imagep = bwareaopen(imagep, 20);
    
    image(~imagep) = 1;
    imageresult = image;
end

