function out = signalDeconv6s(signals, tau, sampleRate)
% SIGNALDECONV6S  Deconvolve signals with GCaMP6s kernel
%
% Description:
%   Deconvolve signals with a GCaMP6s kernel described by the decay time.
%
% Syntax:
%   signals = signalButterFilter(signals, sampleRate, order, cutoffHz)
%
% Input:
%   signals         double (n x t) or (n x t x r)
%       The calcium responses
%   tau             double
%       The decay time constant (default = 1.5), recommended = 1.25-1.5
%   sampleRate      double
%       Sampling frequency in Hz (default = 25)
%
% Output:
%   signals         double (n x t) or (n x t x r)
%       The calcium responses deconvolved
%
% History:
%   25Jan2024 - SSP
% --------------------------------------------------------------------------

    arguments
        signals         double
        tau             double  = 1.25
        sampleRate      double  = 25
    end

    t = 0:(1/sampleRate):5*tau;
    kernel = exp(-t / tau);
    kernel = kernel / sum(kernel);

    paddingLength = ceil(length(kernel)/1.5);
    paddedSignals = padarray(signals, [0 paddingLength 0], 0, 'both');

    out = zeros(size(signals));
    for i = 1:size(signals, 1)
        for j = 1:size(signals, 3)
            iTrace = conv(paddedSignals(i, :, j), kernel, 'full');
            iTrace = iTrace(:, paddingLength+1:paddingLength+size(signals, 2), :);
            out(i, :, j) = iTrace;
        end
    end
