function plotClusterTraces(data, clust, clustID, cmapName)

    if nargin < 4
        cmapName = 'dense';
    end

    idx = find(clust.idx == clustID);
    cmap = slanCM(cmapName, numel(idx));
    figure('Name', ['Cluster ', num2str(clustID)]); 
    hold on;
    for i = 1:numel(idx)
        plot(data(idx(i), :), "Color", cmap(i,:));
    end
    plot(mean(data(idx, :), 1), "Color", "k", "LineWidth", 1.5);
    title(sprintf("Cluster %d (n=%d)", clustID, numel(idx)));

    figPos(gcf, 0.8, 1); tightfig(gcf);