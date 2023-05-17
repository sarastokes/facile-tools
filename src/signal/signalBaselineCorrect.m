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
        for i = 1:size(signals,3)
            signals(:,:,i) = signals(:,:,i) - median(signals(:,bkgd,i),2);
        end
    elseif ndims(signals) == 2
        signals = signals - median(signals(:, bkgd), 2);
    end