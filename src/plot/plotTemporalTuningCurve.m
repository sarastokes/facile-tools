function ax = plotTemporalTuningCurve(dataset, uid, varargin)
    % PLOTTEMPORALTUNINGCURVE
    %
    % Syntax:
    %   plotTemporalTuningCurve(data, tempHzs)
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addOptional(ip, 'X', [1, 5:5:30, 50, 100], @isnumeric);
    addParameter(ip, 'Dots', false, @islogical);
    addParameter(ip, 'Faseb', false, @islogical);
    parse(ip, varargin{:});
    
    tempHzs = ip.Results.X;
    dotFlag = ip.Results.Dots;
    fasebFlag = ip.Results.Faseb;

    temporalStat = dataset.analyses('TemporalStat');
    data = temporalStat(dataset.uid2roi(uid), :);
    data = data/max(abs(data));

    ax = axes('Parent', figure()); hold on;
    h = area(tempHzs, data, 'FaceColor', [0.5 0.5 1], 'EdgeColor', [0.2 0.2 1], 'FaceAlpha', 0.3);
    
    if dotFlag
        co = pmkmp(numel(tempHzs), 'CubicL');
        for i = 1:numel(tempHzs)
            plot(tempHzs(i), data(i), 'Marker', 'o', 'MarkerSize', 6,...
                'Color', co(i,:), 'MarkerFaceColor', lighten(co(i,:)));
        end
        h.EdgeColor = [0.2 0.2 0.2];
        h.FaceColor = [0.7 0.7 0.7];
    end

    axis tight;
    xlim(ax, [0.9, 110]);

    if min(data) > 0 
        ax.YLim(1) = 0;
        ax.YLim(2) = 1;
    end
    if max(data) < 0
        ax.YLim(2) = 0;
    end
    if max(data) > 0.5
        ax.YLim(2) = 1;
    elseif min(data) < -0.5
        ax.YLim(1) = -1;
    end
    showGrid(ax, 'X');
    set(ax, 'XScale', 'log', 'Box', 'off', 'XMinorGrid', 'off', 'YTickLabel', []);
    set(ax, 'XTick', [1 5 10 20 25 30 35 50 100], 'XTickLabelRotation', 45);
    % axis(ax, 'square');
    title(ax, uid);
    %title(ax, sprintf('%s (%.2f)', upper(uid), trapz(tempHzs(1:end-1), data(1:end-1))), 'FontSize', 10);
   
    if fasebFlag
        hideAxes();
        title("");
        grid off;
        figPos(gcf, 0.4,0.3);
        set(gcf, 'PaperPositionMode', 'auto');
        tightfig(gcf);
    else
         figPos(gcf, 0.5, 0.3);
    end