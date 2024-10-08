function [allAvg, N, CI, QI] = plotFeatures(data, clust, xpts, varargin)

    if nargin < 3
        xpts = (1:size(data,2))/25;
    end

    % Messy plotting options
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Omit', false(size(clust.idx)), @islogical);
    addParameter(ip, 'ShowSD', false, @islogical);
    addParameter(ip, 'Parent', [], @ishandle);
    addParameter(ip, 'PlotNum', [], @isnumeric);
    addParameter(ip, 'CMap', [], @isnumeric);
    addParameter(ip, 'Downsample', 0, @isnumeric);
    addParameter(ip, 'Norm', true, @islogical);
    parse(ip, varargin{:});

    % Optional downsampling
    if ip.Results.Downsample > 0
        data = downsampleMean(data, ip.Results.Downsample);
        xpts = downsampleMean(xpts, ip.Results.Downsample);
    end
    % Optional normalization
    if ip.Results.Norm
        data = data ./ max(abs(data), [], 2);
    end

    % Quality and consistency metrics
    QI = cluster.groupQualityIndex(data, clust.idx);
    CI = cluster.consistencyIndex(data, clust.idx);

    % Number of ROIs per cluster
    N = splitapply(@numel, clust.idx, clust.idx);

    parentHandle = ip.Results.Parent;
    plotNum = ip.Results.PlotNum;
    if isempty(plotNum) && ~isempty(parentHandle)
        error('Specify which plot to draw to parent axis');
    end

    if isempty(ip.Results.CMap)
        %co = pmkmp(clust.K, 'CubicL');
        co = othercolor('Spectral10', clust.K);
    else
        co = ip.Results.CMap;
    end

    if isempty(parentHandle)
        figure();
        ax = subplot(3,2,[1 3 5]);
    else
        ax = parentHandle;
    end
    hold(ax, 'on'); grid(ax, 'on');
    allAvg = [];
    if isempty(plotNum) || plotNum == 1
        runningOffset = 0;
        for i = 1:clust.K
            clustData = data(clust.idx == i & ~ip.Results.Omit, :);
            clustAvg = mean(clustData, 1);
            clustAvg = clustAvg/max(abs(clustAvg));
            allAvg = cat(1, allAvg, clustAvg);
            yData = clustAvg+abs(min(clustAvg)) + runningOffset;
            if ip.Results.ShowSD
                clustSD = std(clustData, [], 1);
                shadedErrorBar(xpts-min(xpts), yData, clustSD,...
                    'lineProps', {'LineWidth', 2.5, 'Color', co(i,:)},...
                    'patchSaturation', 0.3);
                runningOffset = max(yData+clustSD) + 0.2;
            else
                h = plot(ax, xpts-min(xpts), yData, 'Color', co(i,:), 'LineWidth', 2.5);
                runningOffset = max(h.YData)+ 0.2;
            end
            text(xpts(end)+(xpts(2)-xpts(1))*3, yData(end), num2str(N(i)),...
                "FontName", "Helvetica", "FontSize", 8, "Color", co(i,:));
            
        end
        axis tight
        xlabel(ax, 'Time (sec)');
        yticks(ax, []);
        ylabel(ax, 'Normalized Response');
        ax.YLim = ax.YLim + 0.025*[-diff(ax.YLim), diff(ax.YLim)];
        reverseChildOrder(gca);
    end

    if isempty(plotNum) || plotNum == 2
        if isempty(parentHandle)
            ax = subplot(3,2,2);
        else
            ax = parentHandle;
        end
        N = splitapply(@numel, clust.idx, clust.idx);
        bar(ax, 1:clust.K, N, 'FaceColor', 'flat', 'CData', co);
        ylabel(ax, 'Number of ROIs'); % xlabel(ax, 'Cluster');
        axis(ax, 'square');
        grid(ax, 'on');
        xlim([0 clust.K+1]);
        xticks(1:clust.K);
    end

    if isempty(plotNum) || plotNum == 3
        if isempty(parentHandle)
            ax = subplot(3,2,4);
        else
            ax = parentHandle;
        end
        hold on;
        bar(ax, 1:clust.K, CI, 'FaceColor', 'flat', 'CData', co);
        ylabel(ax, 'Consistency Index'); % xlabel(ax, 'Cluster');
        axis(ax, 'square'); grid(ax, 'on');
        xlim(ax, [0 clust.K+1]); xticks(ax, 1:clust.K);
        ylim(ax, [0 1]);
    end

    % Quality index plot
    if isempty(plotNum) || plotNum == 4
        if isempty(parentHandle)
            ax = subplot(3,2,6);
        else
            ax = parentHandle;
        end
        hold on;
        bar(ax, 1:clust.K, QI, 'FaceColor', 'flat', 'CData', co);
        xlabel(ax, 'Cluster'); ylabel(ax, 'Quality Index');
        axis(ax, 'square');
        grid(ax, 'on');
        xlim(ax, [0 clust.K+1]); xticks(ax, 1:clust.K);
        ylim(ax, [0 1]);
    end

    drawnow;