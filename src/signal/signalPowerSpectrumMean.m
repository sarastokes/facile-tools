function [y, f] = signalPowerSpectrumMean(signals, sampleRate, varargin)


    ip = inputParser();
    ip.KeepUnmatched = true;
    ip.CaseSensitive = false;
    addParameter(ip, 'Sigma', [], @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    signals = squeeze(signals);

    y = []
    for i = 1:size(signals, 2)
        if ~isempty(ip.Results.Sigma)
            x = smoothcut(signals(:, i), ip.Results.Sigma);
        else
            x = signals(:, i);
        end
        [p, f] = signalPowerSpectrum(x, sampleRate);
        y = cat(2, y, p);
    end

    if ip.Results.Plot
        ax = axes('Parent', figure());
        plot(ax, f, p, 'Tag', 'PowerSpectrum');
        xlim([0, sampleRate / 2]);
        grid on;
    end

