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

a= [];
position = 1;
for p = 1:(length(staffRows)-1)
    if(mod(p,5) == 0)
        position = position+1; 
    end
    a(position) = staffRows(position+1)-staffRows(position);
    if(mod(p,5) ~= 0)
   position = position + 1;
    end 
end 
a = a';
a(a==0) = [];

StaffDistance = sum(a) / length(a);
staffPosition = a;
end