function signals = signalBaselineCorrect(signals, bkgdWindow, method)
% SIGNALBASELINECORRECT
%
% Description:
%   Correct baseline offset by subtracting the mean/median of the background
%   region. Good after high-pass filtering etc.
%
% Syntax:
%   signals = signalBaselineCorrect(signals, bkgdWindow)
%   signals = signalBaselineCorrect(signals, bkgdWindow, medianFlag)
%   [signals, bkgdValue] = signalBaselineCorrect(...)
%
% Inputs:
%   signals         ndarray with time along 2nd dimension
%   bkgdWindow      [1 x 2] frame start/stop
% Optional inputs:
%   method          [1 x 1] string ("median" or "mean")
%       Method for estimating baseline offset (default "mean")
%
% Outputs:
%   signals         baseline corrected signals
%   bkgdValue       background value subtracted from signals
%
% See also:
%   SIGNALHIGHPASSFILTER
%
% History:
%   11May2022 - SSP
%   24Mar2024 - SSP - added medianFlag, better indexing
%   03Apr2024 - SSP - added output bkgdValue
% -------------------------------------------------------------------------

    arguments
        signals
        bkgdWindow  (1,2)       {mustBeInteger}
        method      (1,1)       {mustBeMember(method, ["median", "mean"])} = "mean"
    end

    idx = window2idx(bkgdWindow);
    bkgdValues = ndindex(signals, 2, idx);
    if strcmp(method, "median")
        bkgdValue = median(bkgdValues, 2);
    elseif strcmp(method, "mean")
        bkgdValue = mean(bkgdValues, 2);
    end
    signals = signals - bkgdValue;
