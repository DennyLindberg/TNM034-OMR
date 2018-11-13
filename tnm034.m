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
    
imagesrc = "images/im13s.jpg";
notes = loadimage(imagesrc);
notes = alignstaffshorizontally(notes, 0.8);
notes = prepareforsegmentation(notes, 64, 0.5);
imshow(notes);


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