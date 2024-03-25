function [out, outDiff] = roiPrctFilt(signals, pct, windowSize, shiftSize)
% ROIPRCTFILT
%
% References:
%   Wrapper for prctfilt in CaImAn-MATLAB
% --------------------------------------------------------------------------

    arguments
        signals
        pct         (1,1)       {mustBeInRange(pct, 1, 99)} = 30
        windowSize  (1,1)       {mustBeInteger}             = 1000
        shiftSize   (1,1)       {mustBeInteger}             = windowSize
    end

    [n, t, r] = size(signals);
    out = zeros(n, t, r);
    for i = 1:size(signals, 3)
        out(:,:,i) = prctfilt(signals(:,:,i), pct, windowSize, shiftSize);
    end

    if nargout > 1
        outDiff = signals - out;
    end