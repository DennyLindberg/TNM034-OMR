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

%% Pre-processing (Grade 4/5)


%% Geometric transform (Denny)

% Morphomoical operations
im = 'Images/TestStaff.jpg';
original = loadimage(im);
original = extractnotesfromphoto(original);
% Locate and rotate to be horizontal
original = alignstaffshorizontally(original);

%notesBlurry = extractnotesfromphoto(loadimage('Images/im13c.jpg'));

%figure;
%subplot(1,2,1); imshow(notesRotated);
%subplot(1,2,2); imshow(notesBlurry);


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