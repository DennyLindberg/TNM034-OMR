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

imagePath = 'Images/im10c.jpg';
drawDebug_alternatingStaffs = true;
staffNormalizedWidth = 2048;

%% Pre-processing (Grade 4/5)


%% Geometric transform (Denny)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load image and remove background
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    original = imread(imagePath);
    originalgray = im2double(rgb2gray(original)); 
    [notes, region] = removeBackground(originalgray);   
    notes = notes(region(2):region(4), region(1):region(3));

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extract alpha of staff lines and create an enclosing
    % mask for each staff.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lineSearch_angleLimit = 10;
    lineSearch_angleStep = 1;
    lineSearch_minimumLength = round(size(notes,2)*0.4);
    
    % Expand image, otherwise the structuring element might fail near the corners
    paddingWidth = round(lineSearch_minimumLength*0.2);
    paddingHeight = round(paddingWidth*0.2);
    notes = padarray(notes, [paddingHeight, paddingWidth], 1, 'both');
    
    % Attempt to extract the masks
    staffLinesAlpha = getLinesAlphaByAngle(notes, lineSearch_angleLimit, lineSearch_angleStep, lineSearch_minimumLength);
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
    notes = 1-imwarp(1-notes, perspectiveInverse, 'cubic');
    staffLinesAlpha = imwarp(staffLinesAlpha, perspectiveInverse, 'cubic');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Recreate staffsmask post-transform. 
    % Also create a new mask which includes notes hanging
    % outside the staff.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    staffsMask = imclose(staffLinesAlpha, strel('disk', 16, 4));
    staffsMask = (staffsMask > graythresh(staffsMask));
    
    notesMask = (notes < graythresh(notes));
    notesMask = or(notesMask, staffsMask);
    notesMask = bwareaopen(notesMask, size(notes,2));
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use the mask to remove clutter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    notes = 1-(1-notes).*notesMask;  

    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Split image into a separate segment for each staff
    % based on the masks.
    %
    % staff (struct)
    %   .image      bitmap containing notes
    %   .staffMask  logical mask which wraps around the five major staff lines
    %   .notesMask  logical mask which also includes the notes hanging outside the staff
    %   .top        top of first staff line
    %   .bottom     bottom of fifth staff line
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [staffs, staffCount] = splitStaffsBasedOnMasks(notes, staffsMask, notesMask);
    
    % Normalize
    for k=1:staffCount
        scaleFactor = staffNormalizedWidth / size(staffs(k).image, 2);
        
        staffs(k).image     = imresize(staffs(k).image, scaleFactor, 'bicubic');
        staffs(k).staffMask = imresize(staffs(k).staffMask, scaleFactor, 'nearest');
        staffs(k).notesMask = imresize(staffs(k).notesMask, scaleFactor, 'nearest');
        
        staffs(k).top = round(staffs(k).top*scaleFactor);
        staffs(k).bottom = round(staffs(k).bottom*scaleFactor);
    end
    
    % DRAW A DEBUG LINE ON TOP/BOTTOM OF EACH STAFF
    if drawDebug_alternatingStaffs
        for k=1:staffCount
            staffs(k).image = 1-(1-staffs(k).image)*0.1;
            
            line1 = [max(1, (staffs(k).top-3)):min(size(staffs(k).image,1), (staffs(k).top+3))];
            line2 = [max(1, (staffs(k).bottom-3)):min(size(staffs(k).image,1), (staffs(k).bottom+3))];
            staffs(k).image(line1, :) = 0;
            staffs(k).image(line2, :) = 0;
            
            % invert alternating
            if ~mod(k,2)
                staffs(k).image = 1-staffs(k).image;
            end
        end
        figure;
        imshowpair(originalgray, vertcat(staffs.image), 'montage');
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

fourths = [G1 A1 B1 C2 D2 E2 F2 G2 A2 B2 C3 D3 E3 F3 G3 A3 B3 C4 D4 E4];

eights = [g1 a1 b1 c2 d2 e2 f2 g2 a2 b2 c3 d3 e3 f3 g3 a3 b3 c4 d4 e4];
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