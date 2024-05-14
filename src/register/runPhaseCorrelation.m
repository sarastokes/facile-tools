function obj = runPhaseCorrelation(im0, im, tformType, plotFlag)
% RUNPHASECORRELATION
%
% Description:
%   Register with phase correlation
%
% Syntax:
%   [tform, quality, imReg] = runPhaseCorrelation(im0, im, tformType)
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

    obj = PhaseCorrRegistrationResult(tform, 0);
    obj.setSSIMs(newSSIM, oldSSIM);

    fprintf('SSIM changed from %.3f to %.3f\n', oldSSIM, newSSIM);

