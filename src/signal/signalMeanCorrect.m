function signals = signalMeanCorrect(signals)
    % SIGNALMEANCORRECT
    %
    % Description:
    %   Subtract the average of the full response. Use (with caution) when
    %   there is no viable baseline period before the stimulus
    %
    % Syntax:
    %   signals = signalMeanCorrect(signals)
    %
    % Inputs:
    %   signals         matrix with time in the 2nd dimension
    %
    % History:
    %   27Oct2022 - SSP
    % ---------------------------------------------------------------------
    
    signals = signals - mean(signals, 2);
