function rgbImage = mergePatchToRG(im1, im2, make3D)
% MERGEPATCHTORG
%
% Syntax:
%   rgbImage = mergePatchToRG(im1, im2, make3D)
%
% Inputs:
%   im1        uint8
%       Image for red channel (SUM_AVG)
%   im2        uint8
%       Image for green channel (STD_AVG)
% Optional positional inputs:
%   make3D     logical
%       Make image have empty third channel (default = false)
%
% Outputs:
%   rgbImage    uint8  [x, y, 2/3]
%
% History:
%   07Sep2023 - SSP
% -------------------------------------------------------------------------

    arguments
        im1                 uint8
        im2                 uint8
        make3D      (1,1)   logical = false
    end

    assert(isequal(size(im1), size(im2)), 'Images must be the same size');

    if make3D
        nChannels = 3;
    else
        nChannels = 2;
    end

    rgbImage = zeros(size(im1, 1), size(im1, 2), nChannels, "uint8");

    rgbImage(:,:,1) = im1;
    rgbImage(:,:,2) = im2;