function [ax,handles] = offsetLinePlot(x, data, baseOffset, colors, varargin)
% OFFSETLINEPLOT
%
% Syntax:
%   offsetLinePlot(x, data, offset, colors, varargin)
%
% Inputs:
%   x
%   data            (N x T) matrix
%   baseOffset      scalar
%       Extra offset to add to
%   colors          (N x 3) matrix of RGB values (0-1)
%       Colors for each trace (default = all black)
%   varargin        key/value inputs to plot()
%
% Examples:
%   offsetLinePlot(x, y, 0.2, jet(size(y,1)), "LineWidth", 1.25)
%
% History:
%   19Aug2026 - SSP
% --------------------------------------------------------------------------

    if size(data, 1) == numel(x)
        data = data';
    end
    numTraces = size(data, 1);

    if isempty(colors)
        colors = zeros(numTraces, 3);
    end

    figure(); hold on;
    handles = plot(x, data(1,:), "Color", colors(1,:), varargin{:});
    maxValue = max(data(1,:));

    for i = 2:numTraces
        offset = maxValue + abs(min(data(i,:))) + baseOffset;
        h = plot(x, data(i,:) + offset, "Color", colors(i,:), varargin{:});
        maxValue = max(h.YData);
        handles = cat(1, handles, h);
    end

    set(gca, 'XGrid', 'on', 'TickDir', 'out', 'YTick', []);
    axis tight;
    figPos(gcf, 0.45, 1.25);

    if nargout > 0
        ax = gca;
    end