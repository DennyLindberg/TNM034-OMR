function [noStaffImage] = removeStaff(image)

verticals = image < graythresh(image);
verticals = imopen(verticals, strel('Line',6,90));
disc = verticals; 
disc =imerode(disc, strel('Line',8,90));
disc =imdilate(disc, strel('disk',8,4));

moreContrastVerticals = verticals.*(disc>0.7);
se = strel('cube',1);


noStaffImage = imerode(moreContrastVerticals, se);
noStaffImage = noStaffImage > 0.9;



end