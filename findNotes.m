function [final_image] = findNotes(org,temp)

template = im2double(imread(temp));
level = graythresh(template);
template = im2bw(template,level);
template = 1-template;


orgImg = im2double(imread(org));
level = graythresh(orgImg);
orgImg = im2bw(orgImg,level);
orgImg = 1-orgImg;

tophatFiltered = imtophat(orgImg, strel('Disk',10));

contrastAdjusted = imadjust(tophatFiltered);

final_image = contrastAdjusted;

imshow(final_image);

end
