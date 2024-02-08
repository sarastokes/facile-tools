function plotBIC(clust)

    figure('Name', 'BIC'); hold on; grid on;
    plot(clust.bic, '-ob', 'LineWidth', 1);
    plot(clust.K, clust.bic(clust.K), ...
        'Marker', 'x', 'MarkerSize', 15, 'Color', 'r', 'LineWidth', 2);
    xlabel('Number of Clusters'); ylabel('BIC');
    figPos(gcf, 0.5, 0.5);
    drawnow;