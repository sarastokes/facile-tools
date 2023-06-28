function data = rectify(data, cutoff)
% Rectify the input by making everything <cutoff equal to cutoff
%
% Syntax:
%   y = rectify(x)
%   y = rectify(x, cutoff)
%
% Inputs:
%   x       data to rectify
%   cutoff      double
%       Everything below is set to cutoff value (default = 0)
%
% History:
%   08Feb2023 - SSP
%   02Mar2023 - SSP - Added cutoff option
% -------------------------------------------------------------------------

    if nargin < 2
        cutoff = 0;
    end
    data(data < cutoff) = cutoff;