function [A, xpts] = roiSignals(imStack, L, sampleRate, bkgdWindow, medianFlag)
    % ROISIGNALS
    %
    % Description:
    %   Wrapper for batch running roiSignal for many ROIs
    %
    % Syntax:
    %   [A, xpts] = roiSignals(imStack, L, sampleRate, bkgdWindow, medianFlag)
    %
    % Inputs:  same as roiSignal
    %
    % See also:
    %   ROISIGNAL
    % 
    % History:
    %   06Nov2020 - SSP
    %   02Dec2020 - SSP - Added bkgd estimation options
    % --------------------------------------------------------------------
    
    if nargin < 4
        bkgdWindow = [];
    end
    if nargin < 5
        medianFlag = false;
    end

    L = double(L);

    roiList = unique(L(:));
    roiList(roiList == 0) = [];
    numROIs = numel(roiList);

    A = [];

    for i = 1:numROIs
        [signal, xpts] = roiSignal(imStack, L == roiList(i), sampleRate, bkgdWindow, medianFlag);
        A = cat(1, A, signal);
    end
