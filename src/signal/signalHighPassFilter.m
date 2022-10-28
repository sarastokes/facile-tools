function signals = signalHighPassFilter(signals, cutoffFreq, sampleRate)
    % SIGNALHIGHPASSFILTER
    %
    % Syntax:
    %   signals = signalHighPassFilter(signals, cutoffFreq, sampleRate)
    %
    % Inputs:
    %   signals     double
    %       Signals to high pass filter, [N x T x R] or [N x T]
    %   cutoffFreq  double
    %       Cutoff frequency (hz)
    %   sampleRate  double
    %       Sampling frequency (hz)
    %
    % History:
    %   05May2022 - SSP
    % ---------------------------------------------------------------------
    sampleTime = 1/sampleRate;
    if ndims(signals) == 3
        for i = 1:size(signals, 1)
            for j = 1:size(signals, 3)
                signals(i, :, j) = highPassFilter(squeeze(signals(i,:,j)), cutoffFreq, sampleTime);
            end
        end
    elseif ndims(signals) == 2 %#ok<ISMAT> 
        for i = 1:size(signals, 1)
            signals(i,:) = highPassFilter(signals(i,:), cutoffFreq, sampleTime);
        end
    end