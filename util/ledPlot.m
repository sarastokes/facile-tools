function ledPlot(stim, t)
    % ledPlot
    %
    % Description:
    %   Quick plot of 3 primary timecourses
    % 
    % Syntax:
    %   ledPlot(stim, t)
    %
    % History:
    %   12Dec2021 - SSP

    if size(stim, 1) == 3 && size(stim, 2) ~= 3
        stim = stim';
    end

    if nargin < 2
        t = 1:size(stim, 1);
    end

    figure(); hold on;
    plot(t, stim(:, 1),...
        'Color', hex2rgb('ff4040'), 'LineWidth', 1.5);
    plot(t, stim(:, 2),...
        'Color', hex2rgb('00cc4d'), 'LineWidth', 1.5);
    plot(t, stim(:, 3),...
        'Color', hex2rgb('334de6'), 'LineWidth', 1.5);
    xlim([0 max(t)]);
    grid on;

    figPos(gcf, 0.6, 0.6);
    tightfig(gcf);