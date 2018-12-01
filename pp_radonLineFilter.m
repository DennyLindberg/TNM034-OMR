function [result] = pp_radonLineFilter(image, blockSize, lineCutoff)
    width = size(image, 2);
    height = size(image, 1);
    
    lineCutoff = min(1, max(0, lineCutoff));
    
    % default return value is a copy of the original
    result = image; 
    
    % the filter will be applied in sub-regions.
    blockSize = round(blockSize);
    blockCount = ceil(width/blockSize);
    
    % The width needs to be an even multiple of the block size.
    % Height needs to be the same too.
    newWidth = blockCount*blockSize;
    if width ~= newWidth
       image = ones(blockSize, newWidth);
       image(1:height, 1:width) = result;
    end
    image = image < graythresh(image);
    
    % For each block, extract the dominant lines irregardless of angle.
    theta = 89:0.2:91;%[0:90, 135:179];
    for x=1:blockSize:newWidth
        if (x==newWidth); break; end
        blockEnd = x+blockSize-1;

        % Apply the Radon transform for finding "peaks", which
        % are our lines.
        imageBlock = radon(image(1:height, x:blockEnd), theta);
        maxValue = max(max(imageBlock));
        imageBlock(imageBlock < maxValue*lineCutoff) = 0;     % pick the longest lines
        
        % Inverse transform to get our lines back
        imageBlock = iradon(imageBlock, theta, 'linear', 'Ram-Lak', 1, blockSize);
        imageBlock = imclose(imageBlock > 0.5, strel('disk', 4, 4));
        
        result(1:blockSize, x:blockEnd) = imageBlock;
    end
    
    % Remove any extended result
    result = result(1:height, 1:width);
end

