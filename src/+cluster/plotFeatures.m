function allAvg = plotFeatures(data, clust, xpts, varargin)

    if nargin < 3
        xpts = (1:size(data,2))/25;
    end

    % Messy plotting options
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Omit', false(size(clust.idx)), @islogical);
    addParameter(ip, 'ShowSD', false, @islogical);
    addParameter(ip, 'AreaFill', false, @islogical);
    addParameter(ip, 'Parent', [], @ishandle);
    addParameter(ip, 'PlotNum', [], @isnumeric);
    addParameter(ip, 'cmap', [], @isnumeric);
    addParameter(ip, 'AreaLine', [], @isnumeric);
    addParameter(ip, 'AreaAlpha', 0.35, @isnumeric);
    addParameter(ip, 'Norm', true, @islogical);
    parse(ip, varargin{:});

    if ip.Results.Norm
        data = data ./ max(abs(data), [], 2);
    end

    parentHandle = ip.Results.Parent;
    plotNum = ip.Results.PlotNum;
    if isempty(plotNum) && ~isempty(parentHandle)
        error('Specify which plot to draw to parent axis');
    end


    if isempty(ip.Results.cmap)
        co = pmkmp(clust.K, 'CubicL');
    else
        co = ip.Results.cmap;
    end

    if isempty(parentHandle)
        figure();
        ax = subplot(1,2,1); hold on; grid on;
    else
        ax = parentHandle;
        hold(ax, 'on');
        grid(ax, 'on');
    end
    allPatches = []; allAvg = [];
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
            elseif ip.Results.AreaFill
                if isempty(ip.Results.AreaLine)
                    lColor = co(i,:);
                else
                    lColor = ip.Results.AreaLine;
                end
                if i == 1
                    area(xpts-min(xpts), yData, ...
                        'FaceColor', lighten(co(i,:),0.1), ...
                        'FaceAlpha', ip.Results.AreaAlpha, 'EdgeColor', lColor,...
                        'LineWidth', 1.5);
                else
                    h = shade(xpts-min(xpts), clustAvg);
                    set(h(1), "LineWidth", 1.5, "Color", lColor, ...
                        "YData", h(1).YData + runningOffset + abs(min(clustAvg)));
                    set(h(2:end), "FaceColor", co(i,:), "FaceAlpha", ip.Results.AreaAlpha);

                    if ~isempty(allPatches)
                        newPatches = setdiff(findall(ax, 'Type', 'patch'), allPatches);
                        arrayfun(@(x) set(x, 'YData', get(x, 'YData') + runningOffset + abs(min(clustAvg))), newPatches);
                    end
                    allPatches = findall(ax, 'Type', 'patch');
                end
                runningOffset = max(yData) + 0.2;
            else
                h = plot(ax, xpts-min(xpts), yData, 'Color', co(i,:), 'LineWidth', 2.5);
                runningOffset = max(h.YData)+ 0.2;
            end
        end
        axis tight
        xlabel(ax, 'Time (sec)');
        yticks(ax, []);
        ylabel(ax, 'Normalized Response');
        ax.YLim = ax.YLim + 0.025*[-diff(ax.YLim), diff(ax.YLim)];
        reverseChildOrder(gca);
    end

    if isempty(parentHandle)
        ax = subplot(1,2,2);
    else
        ax = parentHandle;
    end
    if isempty(plotNum) || plotNum == 2
        N = splitapply(@numel, clust.idx, clust.idx);
        bar(ax, 1:clust.K, N, 'FaceColor', 'flat', 'CData', co);
        ylabel(ax, 'Number of ROIs');
        xlabel(ax, 'Cluster');
        axis(ax, 'square');
        grid(ax, 'on');
        xlim([0 clust.K+1]);
        xticks(1:clust.K);
    end