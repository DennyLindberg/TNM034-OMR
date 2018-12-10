%% Run tnm034 for all images
folder = 'Images/';
dirOutput = dir(fullfile('Images/im*.jpg'));
imageFileNames = string({dirOutput.name});

combinedImages = [];
allStaffs = [];
for i=1:size(imageFileNames, 2)
    disp(imageFileNames(i));
    original = im2double(imread(folder + imageFileNames(i)));
    [noteStr, staffs] = tnm034(original);
   % noteStr = tnm034(original);
    
    disp(noteStr);
    
%     imshow(notes);
%     shg;
%     waitforbuttonpress;
    if exist('staffs','var')
        staffSet = struct;
        staffSet.name = imageFileNames(i);
        staffSet.staffs = staffs;
        staffSet.count = size(staffs, 1);
        allStaffs = [allStaffs; staffSet];
    end
end
disp("finished");


%% Staff by staff testing
template = im2double(rgb2gray(imread('Images/template_closed.jpg')));


for i=1:1:size(allStaffs, 1)
    name = allStaffs(i).name;
    staffs = allStaffs(i).staffs;
    staffCount = allStaffs(i).count;
    disp(name);
    
    processedImage = [];
    wholeImage = vertcat(staffs.image);
    
%     [peaks, correlation] = findCorrelationPeaks(wholeImage, template, 0.8);
%     imshowpair(1-wholeImage, correlation);
%     hold on;
%     for k=1:size(peaks,1)
%         p = peaks(k, :);
%         plot(p(1), p(2), '*', 'Color', 'red');
%     end
%     hold off;
    %imshow(cSeg);

%     waitforbuttonpress;
%     continue;
    
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
%             hold on;
%             for k=1:size(peaks,1)
%                 p = peaks(k, :);
%                 plot(p(1), p(2), '*', 'Color', 'red');
%             end
%             hold off;

            
            shg;
            waitforbuttonpress;
        end
        
        processedImage = vertcat(processedImage, staffs(j).image);
    end
    
    strout = "";
    
    for j=1:staffCount
        staffstr = "";
        [staffs(j).notes, debugImage] = parseNotes(staffs(j));
        notes = staffs(j).notes;
        for k=1:size(notes, 1)
            staffstr = staffstr + notes(k).pitch;
        end
        strout = strout+staffstr;
        disp("Staff " + j + ": " + staffstr);
        if j < staffCount
            strout = strout + "n";
        end
        
        
        % DRAW DEBUG
        if true
            %imshow(debugImage); hold on;
            %imshow(1-staffs(j).image); hold on;
            imshow(staffs(j).image); hold on;
            
            if true
                notesCount = size(staffs(j).notes, 1);
                for k=1:notesCount
                    n = staffs(j).notes(k);
                    plot(n.x, n.y, '*', 'Color', 'Red');
                    t = text(n.x, n.y, k + n.pitch, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    t.FontSize = 14;
                    t.FontWeight = 'bold';
                    if n.duration == 4
                        t.Color = 'red';
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
    disp("allStaffs: " + strout);
%     
%     imshow(processedImage);
%     shg;
%     waitforbuttonpress;
    
end
disp("Done");
close all;