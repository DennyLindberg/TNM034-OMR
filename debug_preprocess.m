
%% Find staff groupings using sobel
sobh1 = imfilter(notes, fspecial('sobel'));
notes = imclose(notes, strel('line', 10, 90));
notes = imclose(notes, strel('line', 20, 0));
notes = notes>0.1;
notes = imopen(notes, strel('line', 50, 0));
notes = bwareaopen(notes, size(original, 2)*10);






%%
titanic = imread('Images/im6c.jpg');
allemande = imread('Images/im13c.jpg');

titanic = im2double(titanic);
allemande = im2double(allemande);


titanic_r = titanic(:,:,1);
titanic_g = titanic(:,:,1);
titanic_b = titanic(:,:,1);

%titanic = titanic_b.*titanic_g.*titanic_b;
titanic = rgb2gray(titanic);
%
%titanic = imfilter(titanic, fspecial('log'));
%titanic = imsharpen(titanic, 'Radius', 1, 'Amount', 5);

%titanic = titanic.^0.5;
%titanic = histeq(titanic);
%titanic = imopen(titanic, true(3));

%titanic = histeq(titanic);
%titanic = 1-imfilter(titanic, fspecial('log'));
%titanic = titanic < graythresh(titanic);

%titanic = imgaussfilt(titanic);

%titanic = imsharpen(titanic, 'Radius', 1, 'Amount', 5);
%[titanic, region] = pp_removeBackground(titanic);
%titanic = titanic(region(2):region(4), region(1):region(3));
%titanic = imsharpen(titanic, 'Radius', 1, 'Amount', 5);
%titanic = imsharpen(titanic, 'Radius', 1, 'Amount', 2);
%titanic = wiener2(titanic,[5 5]);

%localMaxImage = imbothat(1-titanic, true(3));





% titanic = rgb2gray(titanic);
% PSF = fspecial('gaussian',2,10);
% INITPSF = ones(size(PSF));
% V = .0001;
% titanic = deconvblind(titanic, INITPSF, 1.0, 0.5);
% imshow(titanic);
% shg;

%imshowpair(titanic, allemande, 'montage');






% Combo one
%titanic = imgaussfilt(titanic);
[titanic, region] = pp_removeBackground(titanic);
% 
% lowerThresh = graythresh(notes)*0.1;
% upperThresh = 1-lowerThresh;                              % value chosen based on manual testing
% notes = imadjust(notes, [lowerThresh, upperThresh]);  % increase contrast and push weak noise to the limits    
% notes = imsharpen(notes, 'Radius', 1, 'Amount', 5);
imshow(titanic);



%%
folder = 'Images/';
dirOutput = dir(fullfile('Images/im*.jpg'));
imageFileNames = string({dirOutput.name});
for i=1:size(imageFileNames, 2)
    disp(imageFileNames(i));
    original = imread(folder + imageFileNames(i));
    original = rgb2gray(im2double(original));
    [notes, region] = pp_removeBackground(original);
    notes = imsharpen(notes, 'Radius', 1, 'Amount', 1);
    
    % Normalize image
    %notes = notes - min(notes(:));
    %notes = notes / max(notes(:));
    %    disp(min(notes(:)));

    %maxval = max(notes(:));
   % notes = histeq(notes);
    %notes = notes.^5;
    %notes = notes < graythresh(notes);
    imshowpair(original, notes, 'montage');
    shg;
    waitforbuttonpress;
end
close all;
