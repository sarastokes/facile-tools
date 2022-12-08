function out = signalBandPassFilter(signals, bpCut, sampleRate)
    % SIGNALBANDPASSFILTER
    %
    % Syntax:
    %   out = signalBandPassFilter(signal, bpCut, sampleRate)
    %
    % Inputs:
    %   signal          [N x T], will be filtered along 2nd dimension
    %   bpCut           [1 x 2], low and high frequency cutoffs in Hz
    %   sampleRate      sampling rate in Hz
    %
    % History:
    %   28Oct2022 - SSP
    % ---------------------------------------------------------------------

    out = zeros(size(signals));
    for i = 1:size(signals, 1)
        out(i,:) = bandpass(signals(i,:), bpCut, sampleRate);
    end
