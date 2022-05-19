function value = minormax(data, whichDim)
    % MINORMAX
    %
    % Description:
    %   Returns the largest divergence from zero (min or max)
    %
    % Syntax:
    %   value = minormax(data, whichDim)
    %
    % History:
    %   11May2022 - SSP
    % ---------------------------------------------------------------------

    if nargin < 2
        whichDim = 1;
    end

    minVal = min(data, [], whichDim);
    maxVal = max(data, [], whichDim);
    if abs(minVal) > abs(maxVal)
        value = minVal;
    else
        value = maxVal;
    end