function [h1, h2] = fillToZero(X, Y, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'ax', [], @ishandle);
    addParameter(ip, 'FaceColor', [0.5 0.5 1], @isnumeric);
    parse(ip, varargin{:});

    ax = ip.Results.ax;
    faceColor = ip.Results.FaceColor;
    if numel(faceColor) == 3
        faceColor = [faceColor; faceColor];
    end

    Y1 = Y;
    Y2 = Y;

    Y1(Y > 0) = 0;
    Y2(Y < 0) = 0;

    if isempty(ax)
        ax = axes('Parent', figure());
    end
    hold(ax, 'on');

    h1 = area(ax, X, Y1, 'FaceColor', faceColor(1,:));
    h2 = area(ax, X, Y2, 'FaceColor', faceColor(2,:));
