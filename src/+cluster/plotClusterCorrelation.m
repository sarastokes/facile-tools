function [corrCoeffs, fh] = plotClusterCorrelation(signals, clust, clustAvg)

    
    if nargin < 3
        clustAvg = cluster.getClusterAverage(signals, clust);
    end

    signals = signals ./ max(abs(signals), [], 2);
    clustAvg = clustAvg ./ max(abs(clustAvg), [], 2);

    corrCoeffs = zeros(numel(clust.idx), 1);
    % TODO: vectorize this
    for i = 1:numel(clust.idx)
        iCorr = corrcoef(signals(i,:), clustAvg(clust.idx(i),:));
        corrCoeffs(i) = iCorr(1,2);
    end

    fh = figure('Name', 'Cluster Correlation'); hold on;
    %set(gca, 'FontName', 'CMU Serif' )
    plotSpread(corrCoeffs, 'distributionIdx', clust.idx, ...
        'distributionColors', othercolor('Spectral10', clust.K));
    xlabel('Cluster ID');
    ylabel(sprintf('Correlation Coefficient (%u +- %.1f)',...
        round(100*mean(corrCoeffs)), 100*std(corrCoeffs)));
    addZeroBarIfNeeded(gca);
    grid on;
    title(sprintf('%u ROIs in %u clusters',...
        size(signals,1), size(clustAvg,1)));
    figPos(gcf, 0.7, 0.8);