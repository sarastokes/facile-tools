function QI = groupQualityIndex(signals, clusterIDs)

    nClusters = numel(unique(clusterIDs));
    QI = zeros(nClusters, 1);

    for i = 1:nClusters
        clustData = signals(clusterIDs == i, :);
        QI(i) = qualityIndex(reshape(clustData, [1 size(clustData)]));
    end