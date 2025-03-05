function f = calcCollimatingLens(divergenceAngle, beamDiameter)
% CALCCOLLIMATINGLENS
%
% INPUTS:
%   divergenceAngle
%       FWHM of the beam divergence angle in degrees
%   beamDiameter
%       Desired output beam diameter in mm
%
% RESOURCES:
% https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=3811&pn=C560TME-B

    f = (beamDiameter/2) / tan(deg2rad(divergenceAngle/2));
