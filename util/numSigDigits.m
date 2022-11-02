function y = numSigDigits(x)
    % NUMSIGDIGITS
    %
    % Description:
    %   Returns the number of significant digits
    %
    % Syntax:
    %   y = numSigDigits(x)
    %
    % History:
    %   01Nov2022 - SSP
    % ---------------------------------------------------------------------
    nDecimals = numel(extractAfter(num2str(abs(x)), '.'));