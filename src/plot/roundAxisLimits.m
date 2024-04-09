function roundAxisLimits(axHandle, whichAxes, symmetryFlag)

    if nargin < 2
        whichAxes = "xy";
    end
    if nargin < 3
        symmetryFlag = false;
    end

    if ~isscalar(axHandle)
        arrayfun(@(x) roundAxisLimits(x, whichAxes, symmetryFlag), axHandle);
        return
    end

    if contains(whichAxes, "x")
        axHandle.XLim = [floor(axHandle.XLim(1)), ceil(axHandle.XLim(2))];
        if symmetryFlag
            axHandle.YLim = max(abs(axHandle.YLim)) *[-1 1];
        end
    end
    if contains(whichAxes, "y")
        axHandle.YLim = [floor(axHandle.YLim(1)), ceil(axHandle.YLim(2))];
        if symmetryFlag
            axHandle.YLim = max(abs(axHandle.YLim))*[-1 1];
        end
    end