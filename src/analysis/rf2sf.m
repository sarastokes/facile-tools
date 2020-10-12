function [y, f] = rf2sf(rf, sampleRate, varargin)
    % RF2SF
    %
    % Description
    %   Calculates spatial frequency tuning curve for RF
    %
    % Syntax:
    %   [y, f] = rf2sf(rf, sampleRate)
    %
    % Input:
    %   rf              1D vector
    %       Receptive field
    %   samplingRate    integer
    %       Samples per unit x
    % 
    % Output:
    %   y               1D vector
    %       Spatial frequency tuning curve
    %   f               1D vector
    %       Spatial frequencies
    %
    % History:
    %   11Oct2020 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Plot', false, @islogical);
    addParameter(ip, 'Pad', false, @islogical);
    addParameter(ip, 'Window', [], @isnumeric);
    addParameter(ip, 'Parent', [], @ishandle);
    parse(ip, varargin{:});

    n = numel(rf);

    if ip.Results.Pad
        n = 2 * nextpow2(n);
        ft = fft(rf, n);
    else
        ft = fft(rf);
    end

    f = sampleRate * (0:floor(n/2)) / n;

    p = abs(ft / n) .^ 2;
    pstop = floor(n/2) + 1;
    y = p(1:pstop);
    
    if ~isempty(ip.Results.Window)
        ind = f < ip.Results.Window(1) | f > ip.Results.Window(2);
        f(ind) = [];
        y(ind) = [];
    end
    
    if ip.Results.Plot
        if isempty(ip.Results.Parent)
            figure(); hold on;
            plot(f, y, 'Color', [0 0 0.5], 'LineWidth', 1);
            xlabel('Spatial Frequency');
        else
            plot(ip.Results.Parent, f, y, 'LineWidth', 1);
        end
    end
    

