function ax = sfPlot(x, y, varargin)
    % SFPLOT

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Ctrl', [], @isnumeric);
    addParameter(ip, 'Title', [], @ischar);
    addParameter(ip, 'Parent', axes('Parent', figure()), @ishandle);
    parse(ip, varargin{:});

    ctrl = ip.Results.Ctrl;
    ax = ip.Results.Parent;

    hold(ax, 'on');
    plot(ax, [0, 40], [0 0], 'Color', [0.4 0.4 0.4]);
    plot(ax, x, y, '-o', 'LineWidth', 1,...
        'Color', [0.54, 0.6, 1], 'MarkerFaceColor', [0.77, 0.8, 1]);
    if ~isempty(ctrl)
        % plot(ax, 0, ctrl, '-x', 'LineWidth', 1,... 
        %     'MarkerSize', 10, 'Color', [0.5, 0, 0]);
        plot(ax, [0 40], [ctrl, ctrl], 'LineWidth', 1,...
            'LineStyle', '--', 'Color', [1, 0.6, 0.6]);
    end

    ylabel('dF/F');
    xlabel('Spatial Frequency (cpd)');

    if ~isempty(ip.Results.Title)
        title(ax, ip.Results.Title);
    end

    set(ax, 'FontName', 'Arial');
    figPos(ax.Parent, 0.6, 0.6);