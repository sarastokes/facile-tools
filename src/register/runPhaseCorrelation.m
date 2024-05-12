function [tform, quality, imReg, refObj0] = runPhaseCorrelation(im0, im, tformType, plotFlag)
% RUNPHASECORRELATION
%
% Description:
%   Register with phase correlation
%
% Syntax:
%   [tform, imReg, refObj0, QI] = runPhaseCorrelation(im0, im, tformType)
%
% Inputs:
%   im0         2d image
%       The reference image for the registration
%   im          2D image
%       The image to be registered
% Optional inputs:
%   tformType   string
%       The type of transformation to be used for the registration
%
%
% See also:
%   runMultimodalRegistration, runMonomodalRegistration, imregcorr, ssim
%
% History:
%   28Feb2021 - SSP
%   10May2024 - SSP - streamlined, removed non-rigid registration
% --------------------------------------------------------------------------


    if nargin < 3
        tformType = "similarity";
    end

    refObj0 = imref2d(size(im0));
    refObj = imref2d(size(im));

    % Phase correlation
    tform = imregcorr(im, refObj, im0, refObj0, ...
        'transformtype', tformType, 'Window', true);
    imReg = imwarp(im, refObj, tform, ...
        'OutputView', refObj0, 'SmoothEdges', true);

    if plotFlag
        figure(); imshowpair(im0, imReg);
    end

    oldSSIM = ssim(im, im0);
    newSSIM = ssim(imReg, im0);

    quality = struct('OldSSIM', oldSSIM, 'NewSSIM', newSSIM);
    if newSSIM < oldSSIM
        fprintf('WARNING!!! ');     % Registration failed
        quality.Warning = true;
    else
        quality.Warning = false;
    end
    fprintf('SSIM changed from %.2f to %.2f\n', oldSSIM, newSSIM);