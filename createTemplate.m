function [template] = createTemplate(tempImage,scale)

template = im2double(imread(tempImage));
level = graythresh(template);
template = im2bw(template,level);
template = 1-template;
template = imresize(template,scale,'nearest');

end

