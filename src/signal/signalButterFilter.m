function out = signalButterFilter(signals, sampleRate, order, cutoffHz)
% SIGNALBUTTERFILTER
%
% Description:
%   Butterworth filter a matrix of ROI responses
%
% Syntax:
%   signals = signalButterFilter(signals, sampleRate, order, cutoffHz)
%
% Input:
%   signals         double (n x t) or (n x t x r)
%       The calcium responses
%   sampleRate      double
%       Sampling frequency in Hz (default = 25)
%   order           double
%       Order of the filter (default = 3)
%   cutoffHz        double
%       Cutoff frequency in Hz (default = 5)
%
% See also:
%   signalDeconv6s, signalHighPassFilter, signalLowPassFilter
%
% History:
%   24Jan2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals             double
        sampleRate  (1,1)   double  = 25
        order       (1,1)   double {mustBeInteger} = 3
        cutoffHz    (1,1)   double  = 5
    end

    nyquistFreq = sampleRate / 2;
    normalizedCutoff = cutoffHz / nyquistFreq;
    [b, a] = butter(order, normalizedCutoff, 'low');

    out = zeros(size(signals));
    for i = 1:size(signals, 1)
        for j = 1:size(signals, 3)
            out(i,:,j) = filtfilt(b, a, signals(i,:,j));
        end
    end

