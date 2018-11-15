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

notesRotated = extractnotesfromphoto(loadimage("images/im10c.jpg"));
%notesRotated = alignstaffshorizontally(notesRotated, 0.8);

notesBlurryPhoto = extractnotesfromphoto(loadimage("images/im13c.jpg"));

figure;
subplot(1,2,1); imshow(notesRotated);
subplot(1,2,2); imshow(notesBlurryPhoto);


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