function out = rectificationIndex(signals, pct)
% RECTIFICATIONINDEX
%
% Syntax:
%   out = rectificationIndex(signals, pct)
%
% Inputs:
%   signals         [n x t] or [n x t x r] matrix of responses
% Optional inputs:
%   pct             percentile for range calculation (default = 2)
%
% See also:
%   roiRangePercentile
%
% History:
%   04May2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals     double
        pct         double = 2
    end

    if pct > 50
        pct = 100 - pct;
    end

    [~, minValue, maxValue] = roiRangePercentile(signals, pct);

    out = maxValue ./ (abs(minValue)+maxValue);
