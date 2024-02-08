function h = addCalibrationBarX(ax, xStart, xLength, varargin)
    % ADDCALIBRATIONBARX
    %
    % Description:
    %   Add a calibration bar to the x-axis
    %
    % Syntax:
    %   h = addCalibrationBarX(ax, xStart, xLength, varargin)
    %
    % History:
    %   24Apr2022 - SSP
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'YLoc', [], @isnumeric);
    addParameter(ip, 'YOffset', [], @isnumeric);
    addParameter(ip, 'LineWidth', 1, @isnumeric);
    parse(ip, varargin{:});

    yLoc = ip.Results.YLoc;
    yOffset = ip.Results.YOffset;

    x = ax.XLim; y = ax.YLim;
    if isempty(yLoc) && isempty(yOffset)
        yLoc = y(1);
    elseif ~isempty(xOffset)
        yLoc = y(1) - yOffset;
    end

    % Add y-axis calibration
    h = plot([xStart, xStart+xLength], [yLoc yLoc], ...
        'k', 'LineWidth', ip.Results.LineWidth, 'Tag', 'CalibrationBar');

    % Add the offset value to the x-axis
    if yLoc < y(1)
        y(1) = yLoc;
    end
    % Otherwise, ensure axis limits remain the same
    ax.XLim = x; ax.YLim = y;

    % Don't need axes anymore 
    hideAxes(gca);
