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
    
notesRotated = loadimage("images/im13s.jpg");
notesRotated = alignstaffshorizontally(notesRotated, 0.8);
notesRotated = prepareforsegmentation(notesRotated, 64, 0.5);

notesBlurryPhoto = loadimage("images/im13c.jpg");
notesBlurryPhoto = prepareforsegmentation(notesBlurryPhoto, 64, 0.5); 

emphasizedNotes = emphasizenotes(loadimage("images/im13c.jpg"));

figure;
subplot(2,2,1); imshow(notesRotated);
subplot(2,2,3); imshow(notesBlurryPhoto);
subplot(2,2,4); imshow(emphasizedNotes);


%% Segmentation (Thobbe)

% Detection

% Thresholding

    % level = graythrash(i);

% Cleaning up



    % L = bwlabel(BW,n)
    % Stats = regionprops(c,properties)

% Staff identification
 
    % Locate and rotated to be horizontal
    
    % Horizontal projection
    
    % Hough transformation

% Staff removal

% labeling (Elias)



%% Classification (Elias) 

% Decision theory


 
%% Symbolic description





end