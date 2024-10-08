function [leafOrder, distances, Z] = plotDendrogram(feat, clust)
%
% History:
%   29May2024 - SSP
% --------------------------------------------------------------------------

    try
        clustFeat = splitapply(@mean, feat', clust.idx);
    catch
        clustFeat = zeros(clust.K, size(feat, 1));
        for i = 1:clust.K
            clustFeat(i, :) = mean(feat(:, clust.idx == i), 2);
        end
    end
    distances = pdist(clustFeat);
    Z = linkage(distances);
    leafOrder = optimalleaforder(Z, distances);


    ax = axes('Parent', figure('Name', 'Dendrogram'));
    d = dendrogram(Z, 'Reorder', leafOrder);
    set(d, 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1]);
    ylim([0, ceil(ax.YLim(2))]);
    hold(ax, 'on');

    %co = pmkmp(obj.clust.K, 'CubicL');
    co = othercolor('Spectral10', clust.K);
    for i = 1:numel(leafOrder)
        plot(ax, i, 0.75, 'Marker', 's', 'MarkerSize', 15,...
            'MarkerFaceColor', co(i, :), 'MarkerEdgeColor', co(i, :));
    end
    figPos(ax.Parent, 0.7, 0.7);
    drawnow;