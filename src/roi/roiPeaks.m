function [peakValues, peakTimes] = roiPeaks(signals, opts)
% TODO: Sign-corrected peak values
    arguments
        signals                 double
        opts.Abs    (1,1)       logical = true
        opts.Time               double  = []
    end

    if ~opts.Abs
        signals = abs(signals);
    end

    [peakValues, peakTimes] = max(signals, [], 2);
    peakValues = squeeze(peakValues);
    peakTimes = squeeze(peakTimes);

    if ~isempty(opts.Time)
        assert(numel(opts.Time) == size(signals, 2),...
            'Time points must match 2nd dimension of response matrix');
        peakTimes = opts.Time(peakTimes);
    end

