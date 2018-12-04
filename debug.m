
folder = 'Images/';
dirOutput = dir(fullfile('Images/im*.jpg'));
imageFileNames = string({dirOutput.name});

combinedImages = [];
allStaffs = [];
for i=1:size(imageFileNames, 2)
    disp(imageFileNames(i));
    original = imread(folder + imageFileNames(i));
    [noteStr, staffs] = tnm034(original);
    disp(noteStr);
    
    staffSet = struct;
    staffSet.name = imageFileNames(i);
    staffSet.staffs = staffs;
    staffSet.count = size(staffs, 1);
    allStaffs = [allStaffs; staffSet];
    
%     image = vertcat(staffs.image);
    %debugImage = vertcat(staffs.debugImage);
    %combinedImages = vertcat(combinedImages, image);
    
   
%     for k=1:size(staffs, 1)
%         imshow(staffs(k).image);
%         for j=1:size(staffs(k).notes)
%             n = staffs(k).notes(j);
%             t = text(n.x, n.y, n.pitch);
%             t.Color = 'red';
%         end
%         shg;
%         w = waitforbuttonpress;
%     end
        

end

%% Staff by staff testing

for i=1:size(allStaffs, 1)
    name = allStaffs(i).name;
    staffs = allStaffs(i).staffs;
    staffCount = allStaffs(i).count;
    
    disp(name);
    wholeImage = vertcat(staffs.image);
    imshow(wholeImage);
    shg;
    waitforbuttonpress;
%     for j=1:staffCount
%         staff = staffs(j);
%         staff.notes = parseNotes(staff);
%         
%         imshow(staff.image);
%         hold on;
%         for k=1:size(staff.notes, 1)
%             n = staff.notes(k);
%             plot(n.x, n.y, '*', 'Color', 'Red');
%         end
%         hold off;
%         shg;
%         w = waitforbuttonpress;
%         
%         %disp(j);
%         %image = vertcat(staffs.image);
%         %imshow(image);
%         %shg;
%         %w = waitforbuttonpress;
%     end
    
    strout = "";
    for j=1:staffCount
        notes = staffs(j).notes;
        for k=1:size(notes, 1)
            strout = strout + notes(k).pitch;
        end

        if j < staffCount
            strout = strout + "n";
        end
    end
    disp(strout);
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