function h = addCalibrationBars(ax, xVal, yVal, offsetVal)
    % ADDCALIBRATIONBARS
    %
    % Description:
    %   Add a calibration bar to the SW corner of a plot
    %
    % Syntax:
    %   [hX, hY] = addCalibrationBars(ax, xVal, yVal, offsetVal)
    %
    % History:
    %   22Apr2022 - SSP
    % ---------------------------------------------------------------------
    
    if nargin < 4
        offsetVal = 0.01;
    end

    x = ax.XLim; y = ax.YLim;

    % Add x-axis calibration
    h1 = plot([x(1), x(1)+xVal] - offsetVal, -0.01 + [y(1), y(1)], ...
        'k', 'LineWidth', 1);
    % Add y-axis calibration
    h2 = plot(-offsetVal + [x(1), x(1)], -0.01 + [y(1), y(1)+yVal], ...
        'k', 'LineWidth', 1);

    % Add the offset value to the x-axis
    x(1) = x(1) - offsetVal;
    y(1) = y(1) - 0.01;
    % Otherwise, ensure axis limits remain the same
    ax.XLim = x; ax.YLim = y;

    if nargout == 1
        h = [h1, h2];
    end

    % Don't need axes anymore 
    hideAxes();
