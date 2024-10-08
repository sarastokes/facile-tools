function fh = plotResponseVsCluster(signals, clustIdx, clustAvg, opts)
% PLOTRESPONSEVSCLUSTER
%
% Syntax:
%   fh = plotResponseVsCluster(signals, clustIdx)
%
% Optional key/value inputs:
%   X           vector (default = 1:T)
%       Timing for each sample in the signals
%   ups         [1x2] double (default = [])
%       Start and stop time of the stimulus
%   gridSize    integer (default = 10)
%       Number of rows and columns in the figure
%   counter     integer (default = 0)
%       Which ROI to start with
%
% History:
%   13Oct2023 - SSP
%   04Jun2024 - SSP - Added downsampling
% --------------------------------------------------------------------------

    arguments
        signals
        clustIdx              double      {mustBeInteger}
        clustAvg              double                      = []
        opts.gridSize   (1,1) double      {mustBeInteger} = 5
        opts.X          (1,:) double                      = []
        opts.ups              double                      = []
        opts.Counter    (1,1) double      {mustBeInteger} = 0
        opts.ID
        opts.Downsample (1,1) double      {mustBeInteger} = 0
    end

    if isempty(clustAvg)
        clustAvg = groupMean(signals, clustIdx);
    end
    clustAvg = clustAvg ./ max(abs(clustAvg), [], 2);

    if isempty(opts.X)
        xpts = 1:size(signals, 2);
    else
        xpts = opts.X;
    end

    if opts.Downsample > 0
        signals = downsampleMean(signals, opts.Downsample);
        clustAvg = downsampleMean(clustAvg, opts.Downsample);
        xpts = downsampleMean(xpts, opts.Downsample);
    end

    cmap = othercolor('Spectral10', max(clustIdx));

    fh = figure();
    counter = opts.Counter;
    for i = 1:opts.gridSize
        for j = 1:opts.gridSize
            if counter > size(signals, 1)
                warning('Reached end of responses...');
                return
            end
            counter = counter + 1;
            clustID = clustIdx(counter);
            subplot(opts.gridSize, opts.gridSize, counter-opts.Counter);
            hold on;
            area(xpts, clustAvg(clustID, :),...
                'FaceColor', lighten(cmap(clustID,:), 0.4),...
                'EdgeColor', cmap(clustID,:), 'LineWidth', 1);
            plot(xpts, signals(counter, :)/max(abs(signals(counter,:))),...
                'Color', 'k', 'LineWidth', 1);
            if ~isempty(opts.ups)
                xregion(opts.ups(1,1), opts.ups(1,2),...
                    'EdgeColor', [0.2 0.2 0.2], 'LineStyle', ':', 'FaceAlpha', 0);
            end
            axis tight; ylim([-1.1 1.1]);
            addZeroBarIfNeeded(gca);
            yticks(-1:0.5:1); grid on;
            xticklabels([]); yticklabels([]);
            clustCorr = corrcoef(signals(counter, :), clustAvg(clustID, :));
            title(sprintf('%u (%g)', counter, round(100*clustCorr(1,2))));
        end
        drawnow;
    end
    tightfig(gcf);

