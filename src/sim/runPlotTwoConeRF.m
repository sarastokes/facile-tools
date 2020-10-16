function [rf, sf] = runPlotTwoConeRF(kc, rc, ks, rs, offset, varargin)
    % RUNPLOTTWOCONERF
    %
    % Syntax:
    %   [rf, sf] = runPlotTwoConeRF(kc, rc, ks, rs, offset, varargin)
    % 
    % History:
    %   12Oct2020 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    addParameter(ip, 'FieldOfView', 1, @isnumeric);   % degrees
    addParameter(ip, 'SampleRate', 1000, @isnumeric); % hz
    parse(ip, varargin{:});

    fs = ip.Results.SampleRate;
    fov = ip.Results.FieldOfView;

    x = -(fov/2):(1/fs):(fov/2);
    if rem(numel(x), 2) == 1
        x = x(1:end-1);
    end

    rf = twoConeRF(kc, rc, ks, rs, offset, x);
    [y1, f] = rf2sf(rf, fs); 
    y2 = rf2sf(abs(rf), fs);

    figure();
    subplot(121); hold on; grid on;
    plot(x, rf, 'Color', rgb('green blue'), 'LineWidth', 1);
    xlabel('degrees');
    axis square;

    subplot(122); hold on;
    plot(f, y2, 'Color', [1 0.25 0.25], 'LineWidth', 1);
    plot(f, y1, 'Color', rgb('green blue'), 'LineWidth', 1);
    xlabel('spatial frequency');
    xlim([0.5 50]);
    axis square;

    % Compact output
    rf = [x; rf];
    sf = [f; y1; y2];