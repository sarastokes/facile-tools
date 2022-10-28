function y = smoothcut(x, sigma)
    % SMOOTHCUT
    %
    % Description:
    %   Smooth a signal and cut out edges (useful for frequency analysis)
    %
    % Syntax:
    %   y = smoothcut(x, sigma)
    %
    % Inputs:
    %   x           double, vector
    %       Signal to smooth
    %   sigma       double, 1x1
    %       Smoothing factor
    %
    % See also:
    %   SMOOTH, MYSMOOTH
    %
    % History:
    %   15Feb2022 - SSP
    % ---------------------------------------------------------------------

    if numel(x) <= (2*sigma)
        error('Signal is to small to cut out edge effects!');
    end

    y = smooth(x, sigma);
    y = y(ceil(sigma):end-ceil(sigma));