function y = diffOfExponentials(x, params)
% DIFFOFEXPONENTIALS  Difference of Exponentials
%
% Syntax:
%   y = diffOfExponentials(x, params)
%
% Inputs:
%   x           domain
%   params      [s1 s2 k1 k2]
%
% Formula:
%       F(x) = a*e^(-bx) - c*e^(-dx)
%   where a and c are scale factors and b and d are time constants
%
% References:
%   Equation 6 in Derrington & Lennie (1984) Journal of Physiology
%
% History:
%   30Aug2023 - SSP
% -------------------------------------------------------------------------

    a = params(1); b = params(2); c = params(3); d = params(4);
    y = a*exp(-b*x) - c*exp(-d*x);
