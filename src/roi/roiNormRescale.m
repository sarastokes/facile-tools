function signals = roiNormRescale(signals, bkgdWindow)
% ROINORMRESCALE
%
% Description:
%   A method for normalizing signals with both positive and negative
%   components along with a baseline that must be preserved.
%
% Syntax:
%   signals = roiNormRescale(signals, bkgdWindow)
%
% Inputs:
%   signals         [N x T] or [N x T x R]
%       Responses with time along the 2nd axis
%   bkgdWindow      [1 x 2] integer
%       The start and stop frame for the region used to estimate baseline
%
% See also:
%   RESCALE, ROINORMAVG, ROINORMPERCENTILE, ROIBASELINECORRECT
% -------------------------------------------------------------------------

    arguments
        signals                     {mustBeNumeric}
        bkgdWindow      (1,2)       {mustBeInteger}
    end

    if ndims(signals) == 3
        for i = 1:size(signals, 3)
            signals(:,:,i) = roiNormRescale(signals(:,:,i), bkgdWindow);
        end
        return
    end

    for i = 1:size(signals, 1)
        signals(i,:) = rescale(signals(i,:));
    end
    signals = roiBaselineCorrect(signals, bkgdWindow, "mean");
