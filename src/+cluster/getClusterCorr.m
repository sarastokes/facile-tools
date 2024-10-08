function [internalCorr, externalCorr] = getClusterCorr(data, clust)

    clustAvg = cluster.getClusterAverage(data, clust);
    externalCorr = triu(corrcoef(clustAvg'), 1);

    internalCorr = zeros(size(clustAvg, 1), 1);
    for i = 1:clust.K
        iData = data(clust.idx == i,:);
        R = triu(corrcoef(iData'), 1);
        internalCorr(i) = mean(R(R~=0));
    end