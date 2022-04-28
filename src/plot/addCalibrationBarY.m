function h = addCalibrationBarY(ax, yStart, yLength, varargin)
    % ADDCALIBRATIONBARY
    %
    % Description:
    %   Add a calibration bar to the y-axis
    %
    % Syntax:
    %   h = addCalibrationBarY(ax, yStart, yLength, varargin)
    %
    % History:
    %   24Apr2022 - SSP
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'XLoc', [], @isnumeric);
    addParameter(ip, 'XOffset', [], @isnumeric);
    parse(ip, varargin{:});

    xLoc = ip.Results.XLoc;
    xOffset = ip.Results.XOffset;

    x = ax.XLim; y = ax.YLim;
    if isempty(xLoc) && isempty(xOffset)
        xLoc = x(1);
    elseif ~isempty(xOffset)
        xLoc = x(1) - xOffset;
    end

    % Add y-axis calibration
    h = plot([xLoc xLoc], [yStart, yStart+yLength], ...
        'k', 'LineWidth', 1, 'Tag', 'CalibrationBar');

    % Add the offset value to the x-axis
    if xLoc < x(1)
        x(1) = xLoc;
    end
    % Otherwise, ensure axis limits remain the same
    ax.XLim = x; ax.YLim = y;

    % Don't need axes anymore 
    hideAxes();
