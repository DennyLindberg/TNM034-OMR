function [merged] = mergeCorrelationClusters(p, mergeDistance)
    mergedCount = 0;
    merged = [];
    m = size(p,1);
    while m > 0
        clusters = [];
        n = m;
        e1 = p(m,:);
        while n > 0
            if n ~= m
                e2 = p(n,:);
                distance = sqrt((e1(1)-e2(1))^2 + (e1(2)-e2(2))^2);
                if distance < mergeDistance
                    clusters = [clusters; m, e1];
                    clusters = [clusters; n, e2];
                end
            end
            n = n-1;
        end

        if size(clusters,1) > 0
            coords = clusters(:, 2:3);
            singlePoint = sum(coords, 1)/size(coords,1);
            merged = [merged; singlePoint];

            % Delete merged points
            indices = unique(clusters(:, 1));
            indices = sort(indices, 'descend');
            mergedCount = mergedCount + size(indices,1);
            for n=1:size(indices,1)
                p(indices(n),:) = [];
            end
        elseif size(p,1) > 0
            merged = [merged; p(m,:)];
            p(m,:) = []; % remove
        end

        m = size(p,1);
    end
%     if mergedCount
%         disp("merged " + mergedCount + " points");
%     end
end

