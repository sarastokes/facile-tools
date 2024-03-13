function [y, x] = timeClip(signals, clipRange, dim, xpts)
% Clip out a region of time from a signal
%
% Syntax:
%   y = timeClip(signals, clipRange, dim)
%   [y, x] = timeClip(signals, clipRange, dim, xpts)
%
% Inputs:
%   signals         double, vector or matrix
%       The response(s) to be clipped
%   clipRange       [1 x 2] double, (must be integer)
%       The first X points and the last Y points to remove (0 removes none)
%   dim             scalar integer
%       The time dimension to be clipped
% Optional inputs:
%   xpts            vector
%       The time axis, which will be clipped to match signals
%
% Examples:
%   % Clip out the first 300 and last 50 time points on the 2nd dimension
%   y = timeClip(signals, [300, 50], 2)
%   % Pass the time axis to get an updated, clipped version for plotting
%   [y, x] = timeClip(signals, [300, 50], 2, xpts)
%
% History:
%   10Oct2023 - SSP
% -------------------------------------------------------------------------

    arguments
        signals             double
        clipRange   (1,2)           {mustBeInteger, mustBeNonnegative}
        dim         (1,1)           {mustBeInteger, mustBeNonnegative}
        xpts                double  {mustBeVector} = NaN
    end
    
    if ndims(signals) == 3
        switch dim
            case 1
                y = signals(clipRange(1):end-clipRange(2), :, :);
            case 2
                y = signals(:, clipRange(1):end-clipRange(2), :);
            case 3
                y = signals(:, :, clipRange(1):end-clipRange(2));
        end
    else
        if dim == 2
            y = signals(:, clipRange(1): end-clipRange(2));
        else
            y = signals(clipRange(1):end-clipRange(2), :);
        end
    end

    if nargout > 1 && ~all(isnan(xpts))
        x = xpts(clipRange(1):end-clipRange(2));
    else
        x = [];
    end