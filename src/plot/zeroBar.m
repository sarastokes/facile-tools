function zeroBar(axHandle, whichAxes)

    arguments
        axHandle            matlab.graphics.axis.Axes
        whichAxes   (1,1)   string {mustBeMember(whichAxes, ["x", "y", "xy", "none"])}
    end

    if ~isscalar(axHandle)
        arrayfun(@(x) zeroBar(x, whichAxes), axHandle);
        return
    end

    if whichAxes == "none"
        delete(findall(axHandle, "Tag", "ZeroX"));
        delete(findall(axHandle, "Tag", "ZeroY"));
        return
    end

    if contains(whichAxes, "x")
        delete(findall(axHandle, "Tag", "ZeroX"));
        h = plot(axHandle, axHandle.XLim, [0, 0],...
            "Color", "k", "LineWidth", 0.75,...
            "Tag", "ZeroX");
        noLegend(h); uistack(h, "bottom");
    end

    if contains(whichAxes, "y")
        delete(findall(axHandle, "Tag", "ZeroY"));
        h = plot(axHandle, [0, 0], axHandle.YLim,...
            "Color", "k", "LineWidth", 0.75,...
            "Tag", "ZeroY");
        noLegend(h); uistack(h, "bottom");
    end