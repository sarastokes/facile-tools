function [peakHeight, peakFrames, peakTrace, dffCutoff] = getTransients(signals, snrCutoff, opts)
% GETTRANSIENTS
%
% Syntax:
%   [peakHeight, peakFrames, nPeaks, dffCutoff] = getTransients(signals,...
%       snrCutoff, sampleRate)
%
% History:
%   02Apr2024 - SSP
% -------------------------------------------------------------------------

    arguments
        signals                     
        snrCutoff           (1,1)       double = 0
        opts.SampleRate     (1,1)       double = 25
        opts.Plot           (1,1)       logical = false
    end

    [peakHeight, peakFrames] = findpeaks(signals, "MinPeakHeight", 0);
    nPeaks0 = numel(peakHeight);

    peakSNR = (peakHeight-mean(peakHeight)) / std(peakHeight);
    dffCutoff = mean(peakHeight) + (snrCutoff*std(peakHeight));

    peakHeight = peakHeight(peakSNR >= snrCutoff);
    peakFrames = peakFrames(peakSNR >= snrCutoff);
    nPeaks = numel(peakHeight);


    fprintf('Cutoff (%s SD) is %.3f dF/F\n\tKept %u of %u peaks (%.2f%%)\n', ...
        num2str(snrCutoff), dffCutoff, nPeaks, nPeaks0, (nPeaks/nPeaks0)*100);

    totalTime = size(signals,2) / opts.SampleRate;
    fprintf('\tTransient rate is %.2f/sec\n', nPeaks/totalTime);

    peakTrace = zeros(1, size(signals,2));
    peakTrace(peakFrames) = peakHeight;

    if opts.Plot
        getDetectedTransientStats(peakFrames, peakHeight, opts.SampleRate);
    end