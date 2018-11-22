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
im = 'Images/im3s.jpg';
original = loadimage('Images/im3s.jpg');
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

%% Binary
    % Thresholding
    % level = graythrash(i);

% Cleaning up (remove false objects)

% Correlation and template matching
tempImage = 'Templates\templateHigh2.png';
template = createTemplate(tempImage, 0.9);
noteheads = extractNoteheads(original,template);


%C = normxcorr2(template, 1-notesRotated);
    
% labeling (Elias)

placeCentroids(noteheads,original);
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