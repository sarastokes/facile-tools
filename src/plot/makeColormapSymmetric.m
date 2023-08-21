function makeColormapSymmetric(ax, saturationPt)
% MAKECOLORMAPSYMMETRIC
%
% Syntax:
%   makeColormapSymmetric(ax, saturationPt)
%
% History:
%   21Oct2021 - SSP
%   24May2023 - SSP - Added saturationPt
% -------------------------------------------------------------------------

   
    if nargin < 1
        ax = gca;
    end
    set(ax, 'CLimMode', 'auto');

    if nargin < 2
        saturationPt = 1;
    else
        assert(saturationPt <= 1 && saturationPt >= 0,...
            'Saturation point must be between 0 and 1');
    end

    set(ax, 'CLim', saturationPt * max(abs(get(ax, 'CLim'))) * [-1 1]);
