function setXLimitsAndTicks(xLimits, xInc, axHandle)
    % SETXLIMITSANDTICKS
    %
    % Description:
    %   Default x-axis aesthetics 
    %
    % Syntax:
    %   setXLimitsAndTicks(xLimits, xInc)
    %
    % History:
    %   11Jan2022 - SSP
    % ---------------------------------------------------------------------

    if nargin < 3
        axHandle = gca;
    end

    if numel(xLimits) == 1
        xLimits = [0 xLimits];
    end

    xlim(axHandle, xLimits);
    set(gca, 'XTickLabel', [], 'XTick', 0:xInc:xLimits(2));
