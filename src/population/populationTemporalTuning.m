function [peakCounts, T, normStatPop] = populationTemporalTuning(temporalStat, tempHzs, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'UIDs', []);
    addParameter(ip, 'Cutoff', [], @isnumeric);
    addParameter(ip, 'Title', [], @istext);
    parse(ip, varargin{:});

    cutoff = ip.Results.Cutoff;
    titleStr = ip.Results.Title;
    if ~isempty(ip.Results.UIDs);
        T = ip.Results.UIDs;
    else
        T = table(rangeCol(1, size(temporalStat,1)),...
            'VariableNames', {'ID'});
    end

    % Compute the max stat
    T.Max = max(abs(temporalStat), [], 2);

    % Apply cutoff, if necessary
    if ~isempty(cutoff)
        T.Omit = T.Max < cutoff;
    else
        T.Omit = zeros(height(T), 1);
    end

    % Identify the peak temporal frequencies
    peakHz = [];
    for i = 1:size(temporalStat, 1)
        if T.Omit(i)
            peakHz = cat(1, peakHz, NaN);
        else
            [~, idx] = max(abs(temporalStat(i,:)));
            peakHz = cat(1, peakHz, idx);
        end
    end
    T.PeakHz = peakHz;

    % Number of cells preferring each temporal frequency
    peakCounts = zeros(size(tempHzs));
    for i = 1:numel(tempHzs)
        peakCounts(i) = nnz(peakHz==i & ~isnan(peakHz));
    end

    % Total response across ROIs (normalized within ROIs)
    normStat = temporalStat ./ max(abs(temporalStat), [], 2);
    normStat(T.Omit,:) = 0;
    normStatPop = sum(normStat, 1);

    % Plot cumulative histogram of preferred frequency
    ax1 = axes('Parent', figure('Name', 'Preferred Frequency')); 
    hold(ax1, 'on');
    area(tempHzs, cumsum(peakCounts)/max(cumsum(peakCounts)),...       
        'LineWidth', 2, 'FaceAlpha', 0.2, 'FaceColor', hex2rgb('00cc4d'));
    set(gca, 'XScale', 'log');
    xticks(gca, tempHzs);
    grid(gca, 'on');
    xlim([1 max(tempHzs)]);
    ylabel('Proportion of Cells');
    xlabel('Preferred Temporal Frequency (Hz)');
    if ~isempty(titleStr)
        title(titleStr, 'Interpreter', 'none');
    end
    figPos(gcf, 0.6, 0.6);
    tightfig(gcf);
    pos1 = get(gcf, 'Position');

    % Plot the total response per temporal frequency
    ax2 = axes(figure('Name', 'Total Response')); 
    hold(ax2, 'on');
    area(ax2, tempHzs, normStatPop/max(abs(normStatPop)),...       
        'LineWidth', 2, 'FaceAlpha', 0.2, 'FaceColor', hex2rgb('334de6'));
    set(ax2, 'XScale', 'log');
    xlim(ax2, [1 max(tempHzs)]); ylim(ax2, [0 1]);
    xticks(ax2, tempHzs);
    grid(ax2, 'on');
    ylabel(ax2, 'Total response (normalized)');
    xlabel(ax2, 'Temporal Frequency (Hz)');
    if ~isempty(titleStr)
        title(ax2, titleStr, 'Interpreter', 'none');
    end
    figPos(ax2.Parent, 0.6, 0.6);
    tightfig(ax2.Parent);
    
    % Offset figures
    ax1.Parent.Position(1) = ax1.Parent.Position(1) - ax1.Parent.Position(3) - 10;