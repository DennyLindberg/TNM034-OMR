function strout = tnm034(im)
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Im: Inputimage of captured sheet music. Im should be in
% double format, normalized to the interval [0,1]
%
% strout: The resulting character string of the detected
% notes. The string must follow a pre-defined format.
%
% Your program code.
%%%%%%%%%%%%%%%%%%%%%%%%%%

imagePath = 'Images/TestStaff.jpg';
drawDebug_alternatingStaffs = true;

%% Pre-processing (Grade 4/5)


%% Geometric transform (Denny)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load image and remove background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
original = imread(imagePath);
originalgray = im2double(rgb2gray(original)); 
[image, region] = removeBackground(originalgray);   
image = image(region(2):region(4), region(1):region(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract alpha of staff lines and create an enclosing
% mask for each staff.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lineSearch_angleLimit = 10;
lineSearch_angleStep = 1;
lineSearch_minimumLength = round(size(image,2)*0.4);

% Expand image, otherwise the structuring element might fail near the corners
paddingWidth = round(lineSearch_minimumLength*0.2);
paddingHeight = round(paddingWidth*0.2);
image = padarray(image, [paddingHeight, paddingWidth], 1, 'both');

% Attempt to extract the masks
staffLinesAlpha = getLinesAlphaByAngle(image, lineSearch_angleLimit, lineSearch_angleStep, lineSearch_minimumLength);
staffsMask = imclose(staffLinesAlpha, strel('disk', 16, 4));
staffsMask = (staffsMask > graythresh(staffsMask));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use mask of staffs to detect perspective transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perspective = estimatePerspectiveTransform(staffsMask);
perspectiveInverse = invert(perspective);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply perspective correction to image and alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image = 1-imwarp(1-image, perspectiveInverse, 'cubic');
staffLinesAlpha = imwarp(staffLinesAlpha, perspectiveInverse, 'cubic');
staffsMask = imclose(staffLinesAlpha, strel('disk', 16, 4));
staffsMask = (staffsMask > graythresh(staffsMask));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Split image into a separate segment for each staff
% based on the mask.
%
% staff (struct)
%   .image      bitmap containing notes
%   .mask       logical mask which wraps around the five major staff lines
%   .beginY     top of first staff line
%   .endY       bottom of fifth staff line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[staffs, staffCount] = splitStaffsBasedOnMask(image, staffsMask);


if drawDebug_alternatingStaffs
    for k=1:staffCount
        staffs(k).image = 1-(1-staffs(k).image)*0.2;
        staffs(k).image(staffs(k).staffBeginY, :) = 0;
        staffs(k).image(staffs(k).staffEndY, :) = 0;

        % invert alternating
        if ~mod(k,2)
            staffs(k).image = 1-staffs(k).image;
        end
    end
    figure;
    imshow(vertcat(staffs.image));
end



%% Segmentation (Thobbe)
% Staff 
    % identification
    % Horizontal projection

    % Staff removal
    sheet = removeStaff(original);
    
    % Save staff position
    [staffPosition, staffDistance] = StaffInformation(original);
    staffSize = (staffDistance - 10)/10;

%% Binary
    % Thresholding
    % level = graythrash(i);

% Cleaning up (remove false objects)

% Correlation and template matching
tempImage = 'Templates\templateHigh3.png';
template = createTemplate(tempImage, 1.0+staffSize);
noteheads = extractNoteheads(original,template);


%C = normxcorr2(template, 1-notesRotated);
    
% labeling (Elias)

placeCentroids(noteheads,original);

ycentroids = centroids(:,2);
[sorted,sortIndex] = sort(ycentroids);
centroids = centroids(sortIndex,:);

pitches = findPitch(centroids);

4ths = [G1 A1 B1 C2 D2 E2 F2 G2 A2 B2 C3 D3 E3 F3 G3 A3 B3 C4 D4 E4];

8ths = [g1 a1 b1 c2 d2 e2 f2 g2 a2 b2 c3 d3 e3 f3 g3 a3 b3 c4 d4 e4];
%%
 L = bwlabel(noteheads,4);
 Lmax = max(max(L));
 %L(L~=2) = 0;

 grad = L ./ max(max(L));
 imagesc(grad);
 colormap hot;


%% Classification (Elias) 

finalimage = findNotes('Images\im1s.jpg','Templates\templateLow.png');

% Decision theory

%% Symbolic description

%TODO:
% Automatic scaling for template
% Save staff position



end