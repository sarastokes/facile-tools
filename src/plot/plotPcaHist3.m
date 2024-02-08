function [h1, h2, h3] = plotPcaHist3(rgbVals, rgbOrder)
%
% Syntax:
%   [h1, h2, h3] = plotPcaHist3(rgbVals, rgbOrder)
%
% Inputs:
%   rgbVals         [X, Y, 3]
% -------------------------------------------------------------------------

    if nargin < 2
        rgbOrder = 1:3;
    end
    figure(); hold on; grid on;
    
    h1 = histogram(rgbVals(:, :, rgbOrder(1)), 'FaceColor', hex2rgb('ff4040'));
    h2 = histogram(rgbVals(:, :, rgbOrder(2)), 'FaceColor', hex2rgb('00cc4d'));
    h3 = histogram(rgbVals(:, :, rgbOrder(3)), 'FaceColor', hex2rgb('334de6'));
    set([h1, h2, h3], 'LineStyle', 'none', 'FaceAlpha', 0.35);

    figPos(gcf, 0.75, 0.75);