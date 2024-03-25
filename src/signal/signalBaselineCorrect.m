function signals = signalBaselineCorrect(signals, bkgdWindow, medianFlag)
% SIGNALBASELINECORRECT
%
% Description:
%   Correct baseline offset, good for after high-pass filtering 
% 
% Syntax:
%   signals = signalBaselineCorrect(signals, bkgdWindow)
%
% Inputs:
%   signals         ndarray with time along 2nd dimension
%   bkgdWindow      [1 x 2] frame start/stop
%   medianFlag      [1 x 1] logical (default = true)
%       median or mean of background region
%
% See also:
%   SIGNALHIGHPASSFILTER
%
% History:
%   11May2022 - SSP
%   24Mar2024 - SSP - added medianFlag, better indexing
% -------------------------------------------------------------------------

    if nargin < 3
        medianFlag = true;
    end

    idx = window2idx(bkgdWindow);
    bkgdValues = ndindex(signals, 2, idx);
    if medianFlag
        bkgd = median(bkgdValues, 2);
    else
        bkgd = mean(bkgdValues, 2);
    end
    signals = signals - bkgd;
    return
