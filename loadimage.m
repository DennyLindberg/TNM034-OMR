function [loadedimage] = loadimage(imagepath)
    loadedimage = im2double(rgb2gray(imread(imagepath)));
end

