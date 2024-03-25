function signals = signalMeanCorrect(signals, dim, bkgdWindow)
% SIGNALMEANCORRECT
%
% Description:
%   Restore the baseline region to appropriate position following certain
%   filters. If no baseline region is provided, the mean of the full
%   signal is used.
%
% Syntax:
%   signals = signalMeanCorrect(signals)
%   signals = signalMeanCorrect(signals, dim)
%   signals = signalMeanCorrect(signals, dim, baseline)
%
% Inputs:
%   signals         matrix with time in the 2nd dimension
%
% History:
%   27Oct2022 - SSP
% -------------------------------------------------------------------------

    if nargin < 2
        dim = 2;
    end
    if nargin < 3
        bkgd = mean(signals, dim);
    else
        sz = size(signals);
        idx = arrayfun(@(x) 1:x, sz, "UniformOutput", false);
        idx{dim} = bkgdWindow(1):bkgdWindow(2);
        bkgd = mean(signals(idx{:}), dim);
    end

    signals = signals - bkgd;
