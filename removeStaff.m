function [noStaffImage] = removeStaff(image)

verticals = imclose(image, strel('Line',4,90));

disc =imclose(image, strel('disk',2,4));

moreContrastVerticals = verticals.*(disc>0.7);
se = strel('cube',1);


noStaffImage = imerode(moreContrastVerticals, se);
noStaffImage = noStaffImage > 0.9;



end