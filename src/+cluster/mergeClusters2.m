function clust = mergeClusters2(data, clust0, corrThreshold, verbose)

    clust = clust0;
    [internalCorr, R] = cluster.getClusterCorr(data, clust0);

    while max(R(:)) > corrThreshold
        [~, ind] = max(R(:));
        [aa, bb] = ind2sub(size(R), ind);
        fprintf("Merging %u and %u - %.3f (internal R: %.3f and %.3f)\n",...
            aa, bb, R(aa, bb), internalCorr(aa), internalCorr(bb));
        if verbose
            figure('Name', sprintf('Merge %u and %u', aa, bb)); hold on;
            aData = data(clust.idx == aa, :);
            bData = data(clust.idx == bb, :);
            for i = 1:size(aData,1)
                plot(aData(i,:), 'Color', [0.5 0.5 1], 'LineWidth', 0.5);
            end
            for i = 1:size(bData,1)
                plot(bData(i,:), 'Color', [1 0.5 0.5], 'LineWidth', 0.5);
            end
            plot(median(aData, 1), 'Color', [0 0 1], 'LineWidth', 1.5);
            plot(median(bData, 1), 'Color', [1 0 0], 'LineWidth', 1.5);
            title(sprintf("%u and %u - %.3f (%.3f and %.3f)",...
                aa, bb, R(aa, bb), internalCorr(aa), internalCorr(bb)));
            drawnow;
        end

        clust.idx(clust.idx == bb) = aa;

        clust.idx = findgroups(clust.idx);
        clust.K = clust.K - 1;
        [internalCorr, R] = cluster.getClusterCorr(data, clust);
    end

    clustIDs = unique(clust.idx);
    for i = 1:numel(clustIDs)
        clust.idx(clust.idx == clustIDs(i)) = i;
    end
