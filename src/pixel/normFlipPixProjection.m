function projNormFlip = normFlipPixProjection(proj, numPCs)
% Normalize each PC and reverse if largely negative
%
% Description:
%   Intended for image aesthetics when plotting 3 PCs as an RGB image
%
% Syntax:
%   projNormFlip = normFlipPixProjection(proj)
%   projNormFlip = normFlipPixProjection(proj, numPCs)
%
% Inputs:
%   proj            [X Y PC] projection
% Optional inputs:
%   numPCs          Number of PCs to flip (default: all)
%
% History:
%   10Oct2023 - SSP
% -------------------------------------------------------------------------

    if nargin < 2
        numPCs = size(proj, 3);
    end

    projNorm = proj ./ max(abs(proj), [], [1 2]);

    fprintf('Channels flipped: ')
    projNormFlip = projNorm;
    for i = 1:numPCs
        [s, l] = bounds(projNorm(:,:,i), "all");
        if abs(s) > abs(l)
            projNormFlip(:,:,i) = -projNorm(:,:,i);
            fprintf('%u', i);
        end
    end
    fprintf('\n');

