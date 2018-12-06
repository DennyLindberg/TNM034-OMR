%% Run tnm034 for all images
folder = 'Images/';
dirOutput = dir(fullfile('Images/im*.jpg'));
imageFileNames = string({dirOutput.name});

combinedImages = [];
allStaffs = [];
for i=1:size(imageFileNames, 2)
    disp(imageFileNames(i));
    original = imread(folder + imageFileNames(i));
    [noteStr, staffs] = tnm034(original);
    
%     imshow(notes);
%     shg;
%     waitforbuttonpress;
    
    staffSet = struct;
    staffSet.name = imageFileNames(i);
    staffSet.staffs = staffs;
    staffSet.count = size(staffs, 1);
    allStaffs = [allStaffs; staffSet];
end

%% Staff by staff testing

for i=1:1:size(allStaffs, 1)
    name = allStaffs(i).name;
    staffs = allStaffs(i).staffs;
    staffCount = allStaffs(i).count;
    disp(name);
    
    processedImage = [];
    wholeImage = vertcat(staffs.image);
    
    for j=1:staffCount   
        [staffs(j).noteRegions, staffs(j).noteRegionsCount] = separateNotesUsingProjections(staffs(j).image);    
        if false
            temp = staffs(j).image;
            % DEBUG: Show individual regions
            for k=1:staffs(j).noteRegionsCount
                r = staffs(j).noteRegions(k);
                x = r.x;
                y = r.y;
                
                temp(y.start:y.end, x.start:x.end) = 1-temp(y.start:y.end, x.start:x.end);
            end
            imshow(temp);
            shg;
            waitforbuttonpress;
        end
        
        processedImage = vertcat(processedImage, staffs(j).image);
    end
    
    strout = "";
    for j=1:staffCount
        [staffs(j).notes, debugImage] = parseNotes(staffs(j));
        notes = staffs(j).notes;
        for k=1:size(notes, 1)
            strout = strout + notes(k).pitch;
        end
        if j < staffCount
            strout = strout + "n";
        end
        
        
        % DRAW DEBUG
        if true
            %imshow(debugImage); hold on;
            %imshow(1-staffs(j).image); hold on;
            imshowpair(staffs(j).image, debugImage); hold on;
            
            if true
                notesCount = size(staffs(j).notes, 1);
                for k=1:notesCount
                    n = staffs(j).notes(k);
                    plot(n.x, n.y, '*', 'Color', 'Red');
                    t = text(n.x, n.y, n.pitch, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                    t.FontSize = 25;
                    t.FontWeight = 'bold';
                    if n.duration == 4
                        t.Color = 'white';
                    else
                        t.Color = 'magenta';
                    end
                end
            end
            hold off;
            shg;
            waitforbuttonpress;
        end
    end
    disp(strout);
%     
%     imshow(processedImage);
%     shg;
%     waitforbuttonpress;
    
end
disp("Done");
close all;





















%% Debugging - Attempt to extract note heads 
height = size(combinedImages, 1);
width = size(combinedImages, 2);
halfHeight = round(height/2);
%range = 1:halfHeight;
range = halfHeight:height;
image = combinedImages(range, :);
untouched = image;

image(:, [1:20, width-20:width]) = 1; % DO THIS, WE GET RID OF EDGES
image = removeStaff(image);
[labels, labelCount] = bwlabel(noStaffs);



%image = extractNotes(image);

    scaleFactor = size(image, 2)/1024;
    beamErode = round(14*scaleFactor);
    beamClean = max(1, round(1*scaleFactor));
    beamDilate = round(6*scaleFactor);
    removeResidues = round(4*scaleFactor);
    
    beams = imclose(image, strel('line', 10, 0));
    beams = imopen(beams, strel('line', 30, 0));
    beams = imopen(beams, strel('line', 5, 90));
    
    [labels, labelCount] = bwlabel(beams);
    props = regionprops(beams, 'MajorAxisLength');
    removalLimit = 60;  % TODO: Must be set per staff
    for k=1:labelCount
        axisLength = props(k).MajorAxisLength;
        
        if axisLength < removalLimit
            labels(labels == k) = 0;
        end
    end
    beams = labels > 0;
    
    image = image & ~beams;
    
    image = imopen(image, strel('line', 10, 90));
    image = imopen(image, strel('rectangle', [8 12]));
    image = imopen(image, strel('disk', 8, 4));
    



imshowpair(untouched, image);

%height = size(image, 1);
%halfHeight = round(height/2);
%imshowpair(image(1:halfHeight, :), image(halfHeight:height, :), 'montage');