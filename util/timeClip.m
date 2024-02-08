function [y, x] = timeClip(signals, clipRange, dim, xpts)
% Clip out a region of time from a signal
%
% Syntax:
%   y = timeClip(signals, clipRange, dim)
%   [y, x] = timeClip(signals, clipRange, dim, xpts)
%
% Examples:
%   % Clip out the first 300 and last 50 time points on the 2nd dimension
%   y = timeClip(signals, [300, 50], 2);
%
% History:
%   10Oct2023 - SSP
% -------------------------------------------------------------------------

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

    if nargin == 4
        x = xpts(clipRange(1):end-clipRange(2));
    else
        x = [];
    end