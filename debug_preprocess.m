% Experiments in debug


%     temp = wholeImage;
%     temp = imclose(temp, strel('line', 10, 90));
%     temp = imsharpen(temp, 'Radius', 10, 'Amount', 10);
%     temp = imopen(temp, strel('disk', 10, 4));
%     temp = temp > graythresh(temp);
%     wholeImage(temp) = 1;
    
    %temp = conv2(double(wholeImage), ones(3)/9, 'full');
    
    origIm = wholeImage;
    %temp =  imgradient(wholeImage);
    %temp = removeStaff(wholeImage);
    %temp = adapthisteq(temp);
    
    %temp = imgaussfilt(wholeImage, 5);%filter2(fspecial('gaussian', 15, 15), wholeImage);
    %temp = 1-temp;
    
    %temp = imopen(wholeImage, strel('disk', 8, 4));
    %temp = imclose(wholeImage, strel('line', 20, 90));
    
%     temp = imclose(wholeImage, strel('line', 10, 90));
%     temp = medfilt2(temp, [10 10]);
%     sobh1 = imfilter(temp, fspecial('sobel')');
%     sobh2 = imfilter(temp, -fspecial('sobel')');
%     sobv1 = imfilter(temp, fspecial('sobel'));
%     sobv2 = imfilter(temp, -fspecial('sobel'));
%     noStaffImage = (sobh1 > graythresh(sobh1)) | (sobh2 > graythresh(sobh2));
%     noStaffImage = noStaffImage | (sobv1 > graythresh(sobv1)) | (sobv2 > graythresh(sobv2));
%     noStaffImage = imclose(noStaffImage, strel('disk', 15, 4));
%     temp(~noStaffImage) = 1;
    
    %temp = wholeImage;
    %temp = imsharpen(1-temp, 'Radius', 10, 'Amount', 10);
    %temp = imclose(temp, strel('line', 10, 90));
    
%     temp = removeStaff(wholeImage);
%     temp = imsharpen(temp, 'Radius', 10, 'Amount', 10);
%     temp = temp < graythresh(temp);
%     temp = bwskel(temp);
    
    %temp = ordfilt2(wholeImage,50,true(10));

    temp = wholeImage;
    temp = integralImage(temp);
    %temp = fibermetric(1-temp); % "tubular structures"
    %temp = imdiffusefilt(wholeImage); % softens noise without blur
    
    %BW2 = bwareafilt(BW,n,keep) % keep n objects
    
    %temp = rangefilt(temp, [1 1 1]); % alternative to sobel
    %temp = stdfilt(wholeImage); % emphasizes edges
    %temp = adapthisteq(temp);
    
    %temp = entropyfilt(temp); % useful for staff detection?
    
    %temp = imextendedmax(wholeImage,0.2); % intressant!
    %temp = imextendedmin(wholeImage, 0.5); % ONLY DOTS AND BEAMS
    %temp = imhmax(wholeImage, 0.4); % similar
    %temp = imhmin(1-wholeImage, 0.4);


    
%% The GOOD stuff

%     temp = wholeImage;
%     temp = imclose(temp, strel('line', 10, 90));
%     temp = imsharpen(temp, 'Radius', 10, 'Amount', 10);
%     temp = imopen(temp, strel('disk', 10, 4));
%     temp = temp > graythresh(temp);
%     wholeImage(temp) = 1;
    
    
    origIm = wholeImage;
    %temp =  imgradient(wholeImage); % all way sobel
    %temp = rangefilt(wholeImage, [1 1 1]); % alternative to sobel (very weak)
    %temp = stdfilt(wholeImage); temp = adapthisteq(temp); % emphasizes edges
    
    %temp = removeStaff(wholeImage);
    %temp = adapthisteq(temp);
    %temp = imsharpen(1-temp, 'Radius', 10, 'Amount', 10);
        
   
    
    %temp = fibermetric(1-temp); % "tubular structures"
    %BW2 = bwareafilt(BW,n,keep) % keep n objects
    %temp = entropyfilt(temp); % useful for staff detection?    
    
    temp = wholeImage;
    
    % THE GOOD STUFF
    % First one of these % the ordfilt2 can be used to enhance and melt important shapes
   % temp = ordfilt2(temp,50,true(15)); % softens noise, blurry, less contrast in intersections
    temp = imdiffusefilt(temp); % softens noise without blur
    
    % Then one of these
    %temp = imhmin(1-temp, 0.4); temp = histeq(temp); % 
    temp = imextendedmin(temp, 1-graythresh(temp)); % Great with imdiffusefilt ONLY DOTS AND BEAMS
    
    % MAYBE
    %temp = imextendedmax(temp, graythresh(temp)); % STRONG THIN CONTRAST
    


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













%% Old parse notes
function [notes, debugImage] = parseNotes(staffStruct)
    notes = [];
    staffHeight = max(1, (staffStruct.bottom - staffStruct.top));
    staffImage = removeStaff(staffStruct.image);

    noteRegions = staffStruct.noteRegions;
    regionsCount = staffStruct.noteRegionsCount;
    
    % Create a second image which greatly simplifies extracting the
    % note heads and beams.  
    beamsAndHeads = 1-staffStruct.image;
    beamsAndHeads = ordfilt2(beamsAndHeads,30,true(10)); % flatten noise (bit blurry)
    beamsAndHeads = 1-imextendedmin(beamsAndHeads, graythresh(beamsAndHeads));
    beamsAndHeads = imdilate(beamsAndHeads, strel('disk', 1, 4));
    beamsAndHeads = bwareaopen(beamsAndHeads, staffHeight); % remove small objects
    
    disp(regionsCount);
    debugImage = zeros(size(staffImage));
    for k=1:regionsCount
        r = noteRegions(k);
        x = r.x;
        y = r.y;
        regionHeight = (y.end-y.start);
        regionWidth = (x.end-x.start);
        regionRatio = regionWidth / regionHeight;
        regionMiddleX = x.start + round(regionWidth/2);
        regionArea = regionWidth*regionHeight;
        [staffPosition, staffFifthLine] = getStaffSplineCoordinates(staffStruct, regionMiddleX);
        staffDistance = staffFifthLine - staffPosition;
        rowStep = staffDistance/4;
        
        imageRegion = staffImage(y.start:y.end, x.start:x.end);
        
        % Remove G-clef by estimating the left limit of the image based
        % on the height of the staff
        if x.start < staffHeight
            continue;
        end
        
        % Remove regions that are not tall enough
        junkCutoffHeight = staffDistance*0.7;
        if regionHeight < junkCutoffHeight
           continue;
        end
        
        % Remove if a region is too small (less than 4 note heads)
        % TODO: Long duration notes without a stem are removed.
        junkCutoffArea = rowStep^2 *4;
        if regionArea < junkCutoffArea; continue; end
        
        % Remove very thin vertical lines
        if regionRatio < 0.25; continue; end 
        

        % Create mask
        mask = imsharpen(imageRegion, 'Radius', 10, 'Amount', 30);
        mask = mask < 0.98;
        
        % Beam detection (may have false positives)
        regionRatio = regionWidth / regionHeight;
        isProbablyASingleNote = regionRatio < 0.6;
        
        noteProps = [];
        notePropsCount = 0;
        if isProbablyASingleNote            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Very likely a single note.
            % There could however be some false
            % shapes.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            noteHeadSize = rowStep;

            % Vertical mask (removes lines and some false positives (vertical beams))
            vmask = imopen(mask, strel('line', round(regionHeight/2), 90));
            vmask = imerode(vmask, strel('line', round(noteHeadSize*0.75), 90));
            vmask = imdilate(vmask, strel('disk', 1, 4));
            mask = mask & ~vmask;
            
            % Detect if a stem is present
            % TODO: Find a much better method
            stemProps = regionprops(vmask, 'MajorAxisLength');
            propsCount = size(stemProps, 1);
            if propsCount == 0
               continue;        % no stem, throw away
            else
                hasStem = false;
                for m=1:propsCount
                    if stemProps(m).MajorAxisLength > rowStep
                        hasStem = true;
                        break;
                    end
                end
                if ~hasStem
                    continue;
                end
            end
            
            % Cleanup some residue
            mask = imopen(mask, strel('disk', 2, 4));
            
            % 90% detection of single notes. (some open notes disappear)
            diskSize = round(rowStep/40 * 16); % Dependent on a good balance here
            mask = imclose(mask, strel('disk', diskSize, 4));
            mask = imopen(mask, strel('disk', diskSize, 4));
            
            % ERASE MASK WHILE TESTING BEAMS
            %mask = 0;
                        
            %mask = beamsAndHeads(y.start:y.end, x.start:x.end);
            debugImage(y.start:y.end, x.start:x.end) = mask;

            
            noteProps = regionprops(mask, 'Centroid');
            notePropsCount = size(noteProps, 1);
        else
            % THE GOOD STUFF
           % imageRegion = adapthisteq(imageRegion);
          % imageRegion = imsharpen(imageRegion, 'Radius', 10, 'Amount', 10);
            %mask = ordfilt2(originalRegion,80,true(10));              % softens noise, blurry, less contrast in intersections
             %mask = imdiffusefilt(imageRegion);                    % softens noise without blur
            %mask = imextendedmin(mask, 1-graythresh(mask)); % Great with imdiffusefilt ONLY DOTS AND BEAMS

            mask = beamsAndHeads(y.start:y.end, x.start:x.end);
            
            
            
            
            
            
            
            
            % Erase masks for beams
            noteHeadSize = rowStep;
            diskSize = round(rowStep/40 * 16 * 0.4);
            %mask = imopen(mask, strel('disk', diskSize, 4));
            
            % Vertical mask (removes lines)
%             vmask = imclose(mask, strel('line', round(regionHeight/3), 90));
%             vmask = imopen(mask, strel('line', round(regionHeight/2), 90));
%             vmask = imerode(vmask, strel('line', round(noteHeadSize*0.75), 90));
%             vmask = imdilate(vmask, strel('disk', 1, 4));
%             mask = mask & ~vmask;
            
            % Clean up small residue
%             mask = imclose(mask, strel('line', round(noteHeadSize/2), 0));
%             mask = imopen(mask, strel('disk', round(noteHeadSize/4), 4));
            
            
            
            % Try to get beams
            % v1
            %sobh = imfilter(imageRegion, fspecial('sobel')); 
            %mask = sobh;
            
            % v2
            %mask = imclose(imageRegion, strel('line', 15, 0));
            %mask = imsharpen(mask, 'Radius', 10, 'Amount', 10);
            %mask = mask < graythresh(mask);
            %mask = imclose(mask, strel('disk', 2, 4));
            %mask = imclose(mask, strel('line', 10, 0));
             
             
             
             %sobh = imdilate(sobh, strel('disk', 2, 4));
%             vmask = sobv1 | sobv2;
%             vmask = imclose(vmask, strel('disk', round(noteHeadSize/3), 4));
            
            %mask = pp_getLinesBySearchAngle(double(~mask), 40, 0.5, 60, 1);
            
            % Attempt to extract note heads
            %diskSize = round(rowStep/40 * 16); % Dependent on a good balance here
            %mask = imclose(mask, strel('disk', diskSize, 4));
            %mask = imopen(mask, strel('disk', diskSize, 4));
            
            % ERASE MASK WHILE TESTING NOTES
            %mask = 0;
            debugImage(y.start:y.end, x.start:x.end) = mask;
            % Detect if note heads are potentially present at all
%             noteHeadSize = rowStep;
%             diskSize = round(rowStep/22 * 9);
%             mask = imopen(mask, strel('line', round(noteHeadSize*0.5), 0));
%             mask = imopen(mask, strel('disk', diskSize, 4));
%             debugImage(y.start:y.end, x.start:x.end) = mask;

            noteProps = regionprops(mask, 'Centroid');
            notePropsCount = size(noteProps, 1);
        end
        
        
        % Use area to determine if it is filled
        % TODO: Are some note heads accidentally removed because of area
        %       or because they are smaller regions?
%         %mask = imopen(mask, strel('disk', 7, 4));
%         filledArea = sum(mask(:) == 1);
%         areaRatio = filledArea / regionArea;
%         %disp(filledArea + " / " + regionArea + " = " + areaRatio);
%         if areaRatio > 0.4
%            % continue;
%         end
        
        
        for m=1:notePropsCount
            centroid = noteProps(m).Centroid;
            cx = centroid(1,1) + x.start;
            cy = centroid(1,2) + y.start;
           
            newNote = struct;
            newNote.x = cx;
            newNote.y = cy;
            newNote.pitch = "G1";
            newNote.duration = 4;

            [firstLine, fifthLine] = getStaffSplineCoordinates(staffStruct, newNote.x);
            localStaffHeight = fifthLine-firstLine;
            pitchStep = localStaffHeight/8;
            hysteresis = pitchStep/2;
            newNote.offset = newNote.y+hysteresis-firstLine;
            pitch = floor((newNote.y-firstLine+hysteresis) / pitchStep); 

            % F3 is the top line
            fourths = ["G1", "A1", "B1", "C2", "D2", "E2", "F2", "G2", "A2", "B2", "C3", "D3", "E3", "F3", "G3", "A3", "B3", "C4", "D4", "E4"];
            indexOffset = 14;
            maxIndex = size(fourths, 2);
            pitch = min(maxIndex, max(1, -pitch+indexOffset));
            newNote.pitch = fourths(pitch);
            isEight = false;
            if isEight
                newNote.pitch = lower(newNote.pitch);
                newNote.duration = 8; 
            end        

            notes = [notes; newNote];
        end
    end
end

