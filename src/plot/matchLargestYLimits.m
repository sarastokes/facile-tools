function matchLargestYLimits(ax, ax1)
    % MATCHLARGESTYLIMITS
    %
    % Description:
    %   Convenience method for multiplots
    %
    % Syntax:
    %   matchLargestYLimits(ax1, ax2)
    %
    % History:
    %   12Jun2022 - SSP
    % ---------------------------------------------------------------------

    if ax.YLim(1) > ax1.YLim(1)
        ax.YLim(1) = ax1.YLim(1);
    elseif ax.YLim(1) < ax1.YLim(1)
        ax1.YLim(1) = ax.YLim(1);
    end
    if ax.YLim(2) < ax1.YLim(2)
        ax.YLim(2) = ax1.YLim(2);
    elseif ax.YLim(2) > ax1.YLim(2)
        ax1.YLim(2) = ax.YLim(2);
    end
