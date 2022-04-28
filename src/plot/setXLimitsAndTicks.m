function setXLimitsAndTicks(xLimits, xInc, axHandle, hideTicks)
    % SETXLIMITSANDTICKS
    %
    % Description:
    %   Default x-axis aesthetics 
    %
    % Syntax:
    %   setXLimitsAndTicks(xLimits, xInc, axHandle, hideTicks)
    %
    % History:
    %   11Jan2022 - SSP
    %   30Mar2022 - SSP, added hide ticks option
    % ---------------------------------------------------------------------

    if nargin < 3
        axHandle = gca;
    end

    if nargin < 4
        hideTicks = false;
    end

    if numel(xLimits) == 1
        xLimits = [0 xLimits];
    end

    xlim(axHandle, xLimits);
    if hideTicks
        set(gca, 'XTick', []);
    else
       set(gca, 'XTickLabel', [], 'XTick', 0:xInc:xLimits(2));
    end
