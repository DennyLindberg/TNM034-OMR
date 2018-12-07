function [peaks, correlation] = findCorrelationPeaks(image, template, limit)
    correlation = normxcorr2(template, image);
    
    xOffset = floor(size(template,2)/2)-1;
    yOffset = floor(size(template,1)/2)-1;
    
    xEnd = size(image,2) + xOffset;
    yEnd = size(image,1) + yOffset;
    
    
    correlation = correlation(yOffset:yEnd, xOffset:xEnd);
    maxVal = max(correlation(:));
    correlation = correlation > maxVal*limit;
    
    corrProps = regionprops(correlation, 'Centroid');
    peaks = [];
    for k=1:size(corrProps, 1)
        c = corrProps(k).Centroid;
        peaks = [peaks; c(1,1), c(1,2)];
    end
end

