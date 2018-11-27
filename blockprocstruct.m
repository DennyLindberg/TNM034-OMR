function [result] = blockprocstruct(image, measurements, fun)
    sizex = size(image, 2);
    sizey = size(image, 1);
    
    % pad image to have an even number of blocks
    blockx = measurements(2);
    blocky = measurements(1);
    countx = floor(sizex/blockx);
    county = floor(sizey/blocky);
    evensizex = countx * blockx;
    evensizey = county * blocky;
    missingx = (countx+1)*blockx - evensizex;
    missingy = (county+1)*blocky - evensizey;
    
    % padded image
    image = padarray(image, [missingy missingx], 'replicate', 'post');
    
    % Debug printout
    %["size", sizey, sizex]
    %["block", blocky, blockx]
    %["missing", missingy, missingx]
    %["newsize", size(image,1), size(image,2)]
    %["count*block", county*blocky, countx*blockx] 
    %["(count+1)*block", (county+1)*blocky, (countx+1)*blockx] 
    
    % run fun for each block
    result = [];
    for y=0:county
        for x=0:countx
            blockstruct = struct;
            blockstruct.border = [0, 0];
            blockstruct.blockSize = measurements;
            blockstruct.data = image((y*blocky+1:(y+1)*blocky), (x*blockx+1:(x+1)*blockx));
            blockstruct.imageSize = size(image);
            blockstruct.location = [y*blocky x*blockx];
            
            result = [result; fun(blockstruct)]; 
        end
    end
end

