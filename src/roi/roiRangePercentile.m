function [out, pctMin, pctMax] = roiRangePercentile(signals, pct)
% ROIRANGEPERCENTILE
%
% Description:
%   Returns the range/trough-to-peak value calculated from the min and max
%   percentile values (default is 2nd and 98th percentiles)
%
% Syntax:
%   [out, pctMin, pctMax] = roiRangePercentile(signals)
%   [out, pctMin, pctMax] = roiRangePercentile(signals, pct)
%
% Inputs:
%   signals             double, (N x T) or (N x T x R)
%   pct                 double scalar
%       The percentile to use for the range calculation (default = 2)
%       The max and min percentiles are calculated as pct and 100-pct
%
% Outputs:
%   out                 double, (N x 1) or (N x R)
%       The range of each response
%   pctMin              double, (N x 1) or (N x R)
%       The min percentile of each response
%   pctMax              double, (N x 1) or (N x R)
%       The max percentile of each response
%
% History:
%   05Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals         double
        pct       (1,1) double  {mustBeInRange(pct, 0, 49)} = 2
    end

    pctMax = prctile(signals, 100-pct, 2);
    pctMin = prctile(signals, pct, 2);
    out = pctMax - pctMin;

    if ndims(signals) == 3
        out = squeeze(out);
        pctMax = squeeze(pctMax);
        pctMin = squeeze(pctMin);
    end
