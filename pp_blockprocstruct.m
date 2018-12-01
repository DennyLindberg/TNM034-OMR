function [result] = pp_blockprocstruct(image, measurements, fun)
    width = size(image, 2);
    height = size(image, 1);
    
    % pad image to have an even number of blocks
    blockWidth = measurements(2);
    blockHeight = measurements(1);
    blockCountX = ceil(width/blockWidth);
    blockCountY = ceil(height/blockHeight);
    evenWidth = blockCountX * blockWidth;
    evenHeight = blockCountY * blockHeight;
    
    % pad image
    result = image; 
    image = ones(evenHeight, evenWidth);
    image(1:height, 1:width) = result;
    
    % run fun for each block
    result = [];
    for y=0:(blockCountY-1)
        for x=0:(blockCountX-1)
            blockstruct = struct;
            blockstruct.border = [0, 0];
            blockstruct.blockSize = measurements;
            blockstruct.data = image((y*blockHeight+1:(y+1)*blockHeight), (x*blockWidth+1:(x+1)*blockWidth));
            blockstruct.imageSize = size(image);
            blockstruct.location = [y*blockHeight x*blockWidth];
            
            result = [result; fun(blockstruct)]; 
        end
    end
end

