function [staffPosition, StaffDistance] = StaffInformation(image)
binaryImage = im2bw(image,0.7);

verticalProfile = sum(binaryImage, 2);
[rows, columns] = size(binaryImage);

imageVector = im2double(verticalProfile);
[pks,locs] = findpeaks((columns-imageVector)); 

maxValue_Peaks = max(pks);
staffs = pks .* (pks > maxValue_Peaks*0.9);

%create an array containing the rows where the stafflines are located (staffRows)
j = locs(:) < staffs(:);
staffRows = j.*locs;
staffRows(staffRows==0) = [];  


StaffDistance = staffRows(2)-staffRows(1);
staffPosition = staffRows; 
end