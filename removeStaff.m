function [noStaffImage] = removeStaff(image)
    height = size(image, 1);

    % Use morphological close on grayscale to weaken the horizontal lines
    image = imclose(image, strel('line', 10, 90));
     
    % Use 4-way sobel filter to extract strong shapes
    sobh1 = imfilter(image, fspecial('sobel')');
    sobh2 = imfilter(image, -fspecial('sobel')');
    sobv1 = imfilter(image, fspecial('sobel'));
    sobv2 = imfilter(image, -fspecial('sobel'));
    noStaffImage = (sobh1 > graythresh(sobh1)) | (sobh2 > graythresh(sobh2));
    noStaffImage = noStaffImage | (sobv1 > graythresh(sobv1)) | (sobv2 > graythresh(sobv2));
    
    % Melt sobel shapes together
    noStaffImage = imclose(noStaffImage, strel('disk', 20, 4));
        
    % Apply sobel shapes to original image so that only the important shapes remain
    image(~noStaffImage) = 1;
    noStaffImage = image;
end