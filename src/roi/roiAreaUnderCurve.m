function aoc = roiAreaUnderCurve(y, aocWindow, sampleRate, rectify)
% ROIAREAUNDERCURVE
%
% Description:
%   Wrapper around trapz for area under the curve analysis
%
% Syntax:
%   aoc = roiAreaUnderCurve(y, aocWindow, sampleRate, rectify)
%
% Inputs:
%   y                   double, [n, t] or [n, t, r]
%       Data to analyze, time must be 2nd dimension
%   aocWindow           double integer, [1 2]
%       Start & stop frame for area under the curve analysis (default, 1:t)
%   sampleRate          double, scalar
%       Rate of data acquisition in Hz (default, 25)
%   rectify             logical, scalar
%       Whether to analyze the absolute value of the data (default, false)
%
% Outputs:
%   aoc                 double, [n, 1] or [n, r]
%
% See also:
%   trapz, window2idx
%
% History:
%   27Feb2024 - SSP
% -------------------------------------------------------------------------

    arguments
        y                   double
        aocWindow   (1,2)   {mustBeInteger, mustBeNonnegative} = [0 0]
        sampleRate  (1,1)   double  {mustBePositive} = 25
        rectify     (1,1)   logical = false
    end

    if isequal(aocWindow, [0 0])
        aocWindow = [1 size(y, 2)];
    end
    aocRange = window2idx(aocWindow);

    if rectify
        y = abs(y);
    end

    aoc = squeeze(trapz(y(:, aocRange, :), 2));
    aoc = aoc / sampleRate;
