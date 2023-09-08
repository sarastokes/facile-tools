function out = mynorm01(data)
% Normalizes data between 0 and 1
%
% Syntax:
%   out = mynorm01(data)
%
% History:
%   22Aug2023 - SSP
% -------------------------------------------------------------------------
    data = data - min(data(:));
    out = data/max(abs(data(:)));
