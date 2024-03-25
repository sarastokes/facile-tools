function noLegend(h)
% NOLEGEND
%
% Description:
%   Ensures the graphics object will not show up in a legend
%
% Syntax:
%   noLegend(h)
%
% Inputs:
%   h       graphics object handle(s)
%
% History:
%   25Mar2024 - SSP
% -------------------------------------------------------------------------

    if ~isscalar(h)
        arrayfun(@(x) noLegend(x), h);
        return
    end

    if ~isgraphics(h)
        error('noLegend:InvalidInput', 'Input must be a graphics object handle, not %s', class(h));
    end

    h.Annotation.LegendInformation.IconDisplayStyle = 'off';