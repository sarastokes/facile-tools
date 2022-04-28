function ledPlot(stim, t, ax)
    % ledPlot
    %
    % Description:
    %   Quick plot of 3 primary timecourses
    % 
    % Syntax:
    %   ledPlot(stim, t, ax)
    %
    % History:
    %   12Dec2021 - SSP
    %   29Dec2021 - SSP - Added option to plot to existing axis
    % ----------------------------------------------------------------

    if size(stim, 1) == 3 && size(stim, 2) ~= 3
        stim = stim';
    end

    if nargin < 2 || isempty(t)
        t = 1:size(stim, 1);
    end
    
    if nargin < 3
        ax = axes('Parent', figure()); 
    end
    hold(ax, 'on');
    
    plot(ax, t, stim(:, 1),...
        'Color', hex2rgb('ff4040'), 'LineWidth', 1.5);
    plot(ax, t, stim(:, 2),...
        'Color', hex2rgb('00cc4d'), 'LineWidth', 1.5);
    plot(ax, t, stim(:, 3),...
        'Color', hex2rgb('334de6'), 'LineWidth', 1.5);
    xlim(ax, [0 max(t)]);
    grid(ax, 'on');

    if nargin < 3
        figPos(gcf, 0.6, 0.6);
        tightfig(gcf);
    end