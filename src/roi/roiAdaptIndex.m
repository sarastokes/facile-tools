function [adaptIndex, maxValues, adaptValues] = roiAdaptIndex(signals, frameRange, endRange, pct)
% ROIADAPTINDEX
%
% Description:
%   Returns an index of adaptation for each ROI measuring the median of the
%   end of the response divided by the max (sign agnostic) of the response
%
% Syntax:
%   adaptIndex = roiAdaptIndex(signals, frameRange, endRange, pct)
%
% Inputs:
%   signals         double, [n x t] or [n x t x r]
%       The responses for one or more ROIs, time must be 2nd dimension
%   frameRange      double, [1 x 2]
%       The range used to look for peak: frameRange(1):end-frameRange
%   endRange        double, [1 x 2]
%       The range used for median adapted value: endRange(1):end-endRange(2)
%   pct             double, [1 x 2], must be in range 0-100
%       The min and max percentiles to use when looking for peak response
%
% Outputs:
%   adaptIndex      double, (n x r), between -1 and 1
%   maxValues       double, (n x r)
%   adaptValues     double, (n x r)
%
% History:
%   03Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals             double
        frameRange   (1,2)  double  {mustBeInteger}
        endRange     (1,2)  double  {mustBeInteger}
        pct          (1,2)  double  {mustBeInRange(pct, 0, 100)}
    end

    maxValues = prctile(signals(:,frameRange(1):end-frameRange(2),:), pct(2), 2);
    minValues = prctile(signals(:,frameRange(1):end-frameRange(2),:), pct(1), 2);
    idx = abs(minValues) > abs(maxValues);
    maxValues(idx) = minValues(idx);

    adaptValues = prctile(signals(:,end-endRange(1):end-endRange(2),:), 50, 2);
    adaptIndex = adaptValues ./ maxValues;

    if ndims(adaptIndex) == 3
        adaptIndex = squeeze(adaptIndex);
        maxValues = squeeze(maxValues);
        adaptValues = squeeze(adaptValues);
    end
