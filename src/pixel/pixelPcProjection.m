function projPix = pixelPcProjection(imStack, U, centerFlag)
% Get the projection of each pixel's timecourse onto PCs
%
% Syntax:
%   projPix = pixelPcProjection(imStack, U)
%   projPix = pixelPcProjection(imStack, U, centerFlag)
%
% Inputs:
%   imStack         [X, Y, T]
%   U               [T, numPCs]
% Optional inputs:
%   centerFlag      logical (default = true)
%       Whether to zero mean the data
%
% Outputs:
%   projPix         [X, Y, numPCs]
%
% History:
%   10Oct2023 - SSP
% -------------------------------------------------------------------------

    if nargin < 3
        centerFlag = true;
    end

    [x, y, t] = size(imStack);
    A = reshape(imStack, [x*y, t]);
    if centerFlag
        A = zscore(A, 0, 2);
    end
    projPix = A * U;
    projPix = reshape(projPix, [x, y, size(U,2)]);
