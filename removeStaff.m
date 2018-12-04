function [noStaffImage] = removeStaff(image)
    scaleFactor = size(image, 2) / 1024;
    rectangleSize = round([5 1] * scaleFactor);
    
    imageBW = image < graythresh(image);
    noStaffImage = imopen(imageBW, strel('rectangle', rectangleSize));
    noStaffImage = imclose(noStaffImage, strel('line', 2, 0));
    noStaffImage = imclose(noStaffImage, strel('line', 2, 90));
end