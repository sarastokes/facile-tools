function signals = signalBaselineCorrect(signals, bkgdWindow)
    % SIGNALBASELINECORRECT
    %
    % Description:
    %   Correct baseline offset, good for after high-pass filtering 
    % 
    % Syntax:
    %   signals = signalBaselineCorrect(signals, bkgdWindow)
    %
    % Inputs:
    %   signals         [N x T]
    %   bkgdWindow      [1 x 2] frame start/stop
    %
    % See also:
    %   SIGNALHIGHPASSFILTER
    %
    % History:
    %   11May2022 - SSP
    % ---------------------------------------------------------------------

    bkgd = window2idx(bkgdWindow);

    if ndims(signals) == 3
        signals = signals - median(signals(:,bkgd,:),2);
    elseif ndims(signals) == 2
        signals = signals - median(signals(:, bkgd), 2);
    end