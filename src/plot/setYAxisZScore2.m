function setYAxisZScore2(axHandle, roundToNearest, hideTicks)
    % SETYAXISZSCORE
    %
    % Description:
    %   Default plotting for z-scored responses
    %
    % Syntax:
    %   yLimits = setYAxisZScore(axHandle, roundToNearest)
    %
    % See also:
    %   ROUNDYAXISLIMITS, SETYTICKSZSCORE
    %
    % History:
    %   11Jan2022 - SSP
    %   30Mar2022 - SSP - Added option to hide y-ticks
    % ---------------------------------------------------------------------

    if nargin < 1
        axHandle = gca;
    end
    
    if nargin < 2
        roundToNearest = [];
    end

    if nargin < 3
        hideTicks = false;
    end
    
    yLimits = roundYAxisLimits(axHandle, roundToNearest);
    if abs(yLimits(1)) > yLimits(2)
        yLimits(2) = abs(yLimits(1));
        ylim(axHandle, yLimits);
    end
    %setYTicksZScore(axHandle);
    set(gca, 'YTick', [floor(axHandle.YLim(1)):1:ceil(axHandle.YLim(2))]);
    if hideTicks
        set(axHandle, 'YTickLabel', {}, 'TickDir', 'in');
    end
    

