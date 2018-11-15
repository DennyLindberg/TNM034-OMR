function [ output_args ] = findNotes( input_args )

template = im2double(imread('Templates\templateLow.png'));
level = graythresh(template);
template = im2bw(template,level);
template = 1-template;

tophatFiltered = imtophat(Original imageimage, Structuring element)

contrastAdjusted = imadjust(tophatFiltered);

imshow(template);

end
