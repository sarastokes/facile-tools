function [innerDiameter, outerDiameter] = coneSegmentDiameters(eccentricity)
% CONESEGMENTDIAMETERS
%
% Description:
%   Returns the inner and outer segment diameters for a given eccentricity
%
% Syntax:
%   [innerDiameter, outerDiameter] = coneSegmentDiameters(eccentricity)
%
% Inputs:
%   eccentricity        double
%       Eccentricity in degrees of visual angle
%
% References:
%    Tyler (1985) Analysis of visual sensitivity. II. Peripheral retina and
%    the role of photoreceptor dimensions. J Opt Soc Am A 2: 393-398.
% --------------------------------------------------------------------------
    innerDiameter = 2.5 * (eccentricity + 0.2) ^ (1/3);
    outerDiameter = 1.4 * (eccentricity + 0.2) ^ (1/5);
end