function [centroids] = placeCentroids(target,original)

stats  = regionprops(target, 'centroid');
centroids = cat(1, stats.Centroid);
imshow(original)
hold on
plot(centroids(:,1), centroids(:,2), 'r*')
hold off

end

