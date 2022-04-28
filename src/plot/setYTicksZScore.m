function yTicks = setYTicksZScore(ax, dontSet)
    % SETYTICKZSCORE
    %
    % Description:
    %   Y-axis numbering for Z-score plots
    %
    % Syntax:
    %   yTicks = setYTicksZScore(ax, dontSet)
    %
    % History:
    %   11Jan2022 - SSP
    % ---------------------------------------------------------------------
    if nargin < 2
        dontSet = false;
    end

    y = get(ax, 'YLim');
    if y(2) >= 4
        yMax = 2 * floor(y(2)/2);
        inc = floor(yMax/2);
    else
        inc = 1;
    end

    yFloor = floor(y(1));

    if abs(yFloor) < inc
        yFloor = -inc;
    end

    yTicks = yFloor:inc:ceil(y(2));

    if ~dontSet
        set(gca, 'YTick', yTicks);
    end