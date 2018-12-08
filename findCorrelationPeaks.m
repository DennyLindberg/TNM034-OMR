function [peaks, correlations, cutoff, maxCorrelation] = findCorrelationPeaks(image, template, limit)
    correlations = normxcorr2(template, image);
    
    xOffset = max(1, floor(size(template,2)/2)-1);
    yOffset = max(1, floor(size(template,1)/2)-1);
    
    xStart = xOffset;
    yStart = yOffset;
    xEnd = size(image,2) + xOffset;
    yEnd = size(image,1) + yOffset;
    
    
    correlations = correlations(yStart:yEnd, xStart:xEnd);
    maxCorrelation = max(correlations(:));
    cutoff = maxCorrelation*limit;
    correlationPeakMask = correlations > cutoff;
    correlationPeakMask = imclose(correlationPeakMask, strel('disk', 4, 4));
    
    corrProps = regionprops(correlationPeakMask, 'Centroid');
    peaks = [];
    for k=1:size(corrProps, 1)
        c = corrProps(k).Centroid;
        peaks = [peaks; c(1,1), c(1,2)];
    end
end

