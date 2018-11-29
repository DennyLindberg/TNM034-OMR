function [squared] = makeSquareSize(image)
    diffx = max(0, size(image,1)-size(image,2));
    diffy = max(0, size(image,2)-size(image,1));
    squared = padarray(image, [diffy diffx], 1);
end

