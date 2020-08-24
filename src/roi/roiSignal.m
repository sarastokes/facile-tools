function [signal, xpts] = roiSignal(imStack, roiMask, sampleRate)
    % ROISIGNAL
    %
    % Syntax:
    %   roiSignal(imStack, roiMask, frameRate);
    % 
    % Inputs:
    %   imStack     3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask     binary 2D matrix [x, Y]
    %       Mask of designating ROI 
    %   sampleRate      numeric (default = 25)
    %       Samples/frames per second (Hz)
    %
    % Outputs:
    %   signal      vector - [1, T]
    %       Average response within ROI over time
    %   xpts        vector - [1, T]
    %       Time points associated with signal 
    %
    % See also:
    %   ROISIGNALPLOT
    % 
    % History:
    %   22Aug2020 - SSP
    % --------------------------------------------------------------------

    if nargin < 3
        sampleRate = 25;  % Hz
    end

    xpts = 1/sampleRate : 1/sampleRate : size(imStack, 3)/sampleRate;

    [a, b] = find(roiMask == 1);
    signal = imStack(a, b, :);
    signal = squeeze(mean(mean(signal, 1), 2));