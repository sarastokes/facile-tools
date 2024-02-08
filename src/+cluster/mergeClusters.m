function [clust, clustAvg] = mergeClusters(signals, clust, rThreshold, nIter)

    arguments
        signals         double
        clust           struct
        rThreshold      double  {mustBeInRange(rThreshold, 0, 1)}
        nIter           double  {mustBeInteger} = 0
    end

    clustAvg = groupMean(signals, clust.idx);

    R = triu(corrcoef(clustAvg'), 1);

    numMerges = 0;
    while max(R(:)) >= rThreshold
        [~, ind] = max(R(:));
        [aa, bb] = ind2sub(size(R), ind);
        fprintf('Merging %u and %u - %.3f\n', aa, bb, R(aa, bb));

        clust.idx(clust.idx == bb) = aa;
        tmp = unique(clust.idx);
        for i = 1:numel(unique(clust.idx))
            newIdx = tmp(i);
            clust.idx(clust.idx == newIdx) = i;
        end

        clust.K = numel(unique(clust.idx));
        clustAvg = groupMean(signals, clust.idx);
        R = triu(corrcoef(clustAvg'), 1);
        numMerges = numMerges + 1;
        if nIter > 0 && numMerges == nIter
            fprintf('Reached max number of merges.  ');
            break
        end
    end


    clustAvg = groupMean(signals, clust.idx);

    fprintf('Merged %u clusters. %u clusters remain\n', numMerges, clust.K);
    fprintf('Max correlation remaining = %.3f\n', max(R(:)));