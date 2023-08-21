function formatTuningMultiPlot(ax)
% Format a multiplot for a temporal tuning curve 
%
% Syntax:
%   formatTuningMultiPlot(ax)
%
% History:
%   03Jun2023 - SSP
% -------------------------------------------------------------------------

    axis(ax, 'tight');
    if ax.YLim(2) >= 10
        set(ax, 'YTick', 0:10:ax.YLim(2));
    end
    xlim([0.9 110]);
    set(ax, 'XScale', 'log', 'YTickLabel', []);
    addZeroBarIfNeeded(ax);
    if ax.YLim(1) > 0
        ax.YLim(1) = 0;
    end
    if ax.YLim(2) >= 10
        set(ax, 'YTick', (10*floor(ax.YLim(1)/10)):10:ax.YLim(2));
    end
    showGrid(ax, 'y');
    reverseChildOrder(ax);

