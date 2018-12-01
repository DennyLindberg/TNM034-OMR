function [result] = pp_straightenImageUsingSplines(image, topSpline, bottomSpline, samplerScale)
    result = image;
    height = size(image, 1);
    width = size(image, 2);

    % This method takes an image and a spline and straightens it out.
    % If two splines are present, both splines are straightened out
    % between the min and max.

    singleSpline = true;
    if nargin < 4; samplerScale = 1.0; end
    if nargin > 2
       singleSpline = isempty(bottomSpline);
    end
    
    % The source image can be rescaled to allow for bicubic sampling for sub-pixel ranges.
    if samplerScale ~= 1.0
        image = imresize(image, [ceil(samplerScale*height), width], 'bicubic');
    end
    
    if singleSpline
        % With a single spline the image columns only needs to be moved up
        % or down.
        topLimit = min(topSpline(:,2));
        for x=1:width
            offset = floor(max(1, topSpline(x)-topLimit));
            copyLength = height-offset+1;
            result(1:copyLength, x) = result(offset:height, x);
            if copyLength < height
                % fill white
                result(copyLength+1:height, x) = 1;
            end    
        end
    else
        % For two splines, the image column not only must be moved but also
        % scaled. 
        topLimit = min(topSpline(:,2));
        bottomLimit = max(bottomSpline(:,2));
        
        % Max height is a reference for how much each column should be
        % resampled.
        maxHeight = bottomLimit-topLimit;
        for x=1:width
            % Sample the splines
            top = topSpline(x);
            bottom = bottomSpline(x);

            % Determine how fast each column should be resampled.
            % (slower rate = scale up)
            samplerRate = (bottom-top)/maxHeight;          % relative scale based on spline distances in the current column
            offset = (top-topLimit*samplerRate);           % how much to offset the column
            sampleRange = offset:samplerRate:height;       % normal unscaled range
            sampleRange = floor(sampleRange*samplerScale); % scale up to sampling range
            
            % If the range is zero we get unlimited scaling because the
            % splines touch. Skip if that is the case.
            if ~isempty(sampleRange)
                if sampleRange(1) <= 0
                    sampleRange = max(1, sampleRange+sampleRange(1));
                end

                copyLength = min(height, size(sampleRange,2));

                result(1:copyLength, x) = image(sampleRange(round(1:copyLength)), x);
                if copyLength < height
                    result(copyLength+1:height, x) = 1; % fill white
                end    
            end
        end
    end
end

