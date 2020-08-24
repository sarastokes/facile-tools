function [p, f] = signalPowerSpectrum(signal, sampleRate, verbose)
    % SIGNALPOWERSPECTRUM
    %
    % Syntax:
    %   [p, f] = signalPowerSpectrum(signal, sampleRate, verbose)
    %
    % Inputs:
    %   signal      vector 
    %       Data for calculating power spectrum
    %   sampleRate      numeric
    %       Samples per second (Hz)
    % Optional inputs:
    %   verbose         logical (default = false)
    %       Plot the output 
    %
    % Outputs:
    %   p               vector
    %       Power spectrum
    %   f               vector
    %       Frequencies (from 0 to sampleRate/2)
    %
    % History:
    %    23Aug2020  - SSP
    % --------------------------------------------------------------------

    if nargin < 3
        verbose = false;
    end

    y = fft(signal);

    f = (0:(length(y)-1))*(sampleRate/length(y));
    p = abs(y) .^ 2/length(y);

    % For simplicity, keep only half
    f = f(1:floor(numel(f)/2));
    p = p(1:floor(numel(p)/2));

    if verbose
        figure(); hold on;
        plot(f, p, 'Tag', 'PowerSpectrum');
        set(gca, 'YScale', 'log');
        title('ROI Power Spectrum');
        xlabel('Frequency (Hz)');
        xlim([0, sampleRate / 2]);
        grid on;
    end