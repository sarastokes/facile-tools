function plotCompareClusters(data, clust, clusterIDs)

    clustAvg = cluster.getClusterAverage(data, clust);

    figure(); hold on;
    for i = 1:numel(clusterIDs)
        shadedErrorBar(1:size(clustAvg,2), clustAvg(clusterIDs(i), :),...
            std(data(clust.idx==clusterIDs(i),:), [], 1),...
            "LineProps", {"LineWidth", 1});
    end
    axis tight; ylim(max(abs(ylim())) * [-1 1]);
    legend("Location", "northoutside", "Orientation", "horizontal");