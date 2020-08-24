function roiSignalPlot(imStack, roiMask, sampleRate)
    % ROISIGNALPLOT
    %
    % Description:
    %   Creates figure showing ROI location (XY) along with signal (T)
    %
    % Syntax:
    %   roiSignalPlot(imStack, roiMask, frameRate);
    % 
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [x, Y]
    %       Mask of designating ROI 
    %   sampleRate      numeric (default = 25)
    %       Samples/frames per second (Hz)
    %
    % See also:
    %   ROISIGNAL, ROIOVERLAY
    %
    % History:
    %   22Aug2020 - SSP
    % --------------------------------------------------------------------

    if nargin < 3
        sampleRate = 25;  % Hz
    end

    if nnz(roiMask) == 0
        error('No data points in roiMask!');
    end
    
    [signal, xpts] = roiSignal(imStack, roiMask, sampleRate);
    
    figure();
    ax = subplot(5, 1, 1:3);
    roiOverlay(squeeze(mean(imStack, 3)), roiMask, 'Parent', ax);
    
    ax = subplot(5, 1, 4:5);
    plot(ax, xpts, signal, 'Color', rgb('navy'));
    grid(ax, 'on');
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Fluourescence (f)');

    figPos(gcf, 1, 1.5);