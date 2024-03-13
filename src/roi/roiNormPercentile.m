function [out, pctMin, pctMax] = roiNormPercentile(signals, pct)
% ROINORMPERCENTILE
%
% Description:
%   Normalize by the maximum absolute value of the signal where the maximum
%   is computed as the Xth or 100-Xth percentile of the signal.
%
% Syntax:
%   [out, pctMin, pctMax] = roiNormPercentile(signals)
%   [out, pctMin, pctMax] = roiNormPercentile(signals, pct)
%
% Inputs:
%   signals             double, (N x T) or (N x T x R)
%   pct                 double scalar
%       The percentile to use for the range calculation (default = 2)
%       The max and min percentiles are calculated as pct and 100-pct
%
% Outputs:
%   out                 double, (N x T) or (N x T x R)
%       The normalized responses
%   pctMin              double, (N x 1) or (N x R)
%       The min percentile of each response
%   pctMax              double, (N x 1) or (N x R)
%       The max percentile of each response
%
% History:
%   05Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals             double
        pct       (1,1)     double  {mustBeInRange(pct, 0, 49)} = 2
    end

    pctMax = prctile(signals, 100-pct, 2);
    pctMin = prctile(signals, pct, 2);

    out = signals ./ max(abs([pctMax, pctMin]), [], 2);

    pctMax = squeeze(pctMax);
    pctMin = squeeze(pctMin);

