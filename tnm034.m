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

notesRotated = extractnotesfromphoto(loadimage('Images/im1s.jpg'));
notesRotated = alignstaffshorizontally(notesRotated);

notesBlurry = extractnotesfromphoto(loadimage('Images/im13c.jpg'));

figure;
subplot(1,2,1); imshow(notesRotated);
subplot(1,2,2); imshow(notesBlurry);


%% Segmentation (Thobbe)

% Staff 
    %identification
    % Locate and rotate to be horizontal
    % Horizontal projection
    % Save staff position
    % Staff removal

%Binary
    % Thresholding
    % level = graythrash(i);

% Cleaning up (remove false objects)

% Correlation and template matching

C = normxcorr2(template, 1-notesRotated);
    
    


% labeling (Elias)

% L = bwlabel(BW,n)
% Stats = regionprops(c,properties)


    %notes2text



%% Classification (Elias) 


finalimage = findNotes('Images\im1s.jpg','Templates\templateLow.png');



% Decision theory
%%
org = 'Images\im1s.jpg';

temp = 'Templates\templateHigh2.png';





template = im2double(imread(temp));
level = graythresh(template);
template = im2bw(template,level);
template = 1-template;




imagesc(C);
colormap default;


%%
orgImg = im2double(imread(org));
level = graythresh(orgImg);
orgImg = im2bw(orgImg,level);
%orgImg = 1-orgImg;
%strel('Disk',5)

%%
image = loadimage('Images\im3s.jpg');
newtemplate = imresize(template,0.9,'nearest');
background = imclose(image, newtemplate);
extractedNotes = imsubtract(background, image);
result = imadjust(extractedNotes, [0.1, 0.5]);  % increase contrast by pushing dark/light areas away from each other

background = background < 0.95;
imshow(background);
 
%% Symbolic description

stats = regionprops(background); 

centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
radii = diameters/2;

% Plot the circles
          hold on
          viscircles(centers,radii);
          hold off
          
          
          

%% 
    s  = regionprops(background, 'centroid');
          centroids = cat(1, s.Centroid);
          imshow(background)
          hold on
          plot(centroids(:,1), centroids(:,2), 'b*')
          hold off

%%
%bwlabel




end