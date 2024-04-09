function clustAvg = getClusterAverage(data, clust)
    
    if isstruct(clust)
        idx = clust.idx;
    end

    assert(numel(idx) == size(data,1));

    nClust = numel(unique(idx));

    clustAvg = [];
    for i = 1:nClust
        clustAvg = cat(1, clustAvg, mean(data(idx == i,:),1));
    end