function plotPulseStats(T, roiID, varargin)
    % PLOTPULSESTATS
    %
    % Syntax:
    %   plotPulseStats(T, roiID, varargin)
    %
    % History:
    %   12May2022 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'X', 1:numel(T.onset(1,:)), @isnumeric);
    parse(ip, varargin{:});

    xpts = ip.Results.X;

    figure(); hold on;
    grid on;
    figPos(gcf, 0.4, 0.5);
    plot(xpts, T.onset(roiID,:), '-o',... 
        'Color', [0.5 0.5 1], 'LineWidth', 1);
    plot(xpts, T.offset(roiID,:), '-o',... 
        'Color', [1 0.5 0.5], 'LineWidth', 1);
    plot(xpts, T.onoff(roiID,:), '-o',... 
        'Color', 'k', 'LineWidth', 1);
    addZeroBar(gca);
    title(sprintf('ROI %u', roiID));
    % legend({'Onset', 'Offset', 'Ratio'},... 
    %     'Location', 'south outside', 'Orientation', 'horizontal');

