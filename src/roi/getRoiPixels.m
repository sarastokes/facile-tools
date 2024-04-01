function [pixelResponses, a, b] = getRoiPixels(imStack, L, roiID)
% GETROIPIXELS
%
% Description:
%   Get responses from individual pixels in a ROI
%
% Syntax:
%   [pixelResponses, a, b] = getRoiPixels(imStack, L, roiID);
%
% Inputs:
%   imStack             uint or double, [X Y T] or [X Y T N]
%   L                   double, labeled matrix of ROIs [X Y]
%   ID                  double integer, which ROI to return pixel responses
%
% Outputs:
%   pixelResponses      [N T] or [N T R] pixel timecourses in ROI
%   a                   row indices of ROI's pixels
%   b                   column indices of ROI's pixels
%
% History:
%   10Nov2021 - SSP - From roiQuality
%   26Mar2024 - SSP - Added support for 4D stacks (multiple repeats)
% --------------------------------------------------------------------------

    if ~isa(L, 'double')
        L = double(L);
    end

    if ndims(imStack) == 4
        pixelResponses = zeros(nnz(L==roiID), size(imStack, 3), size(imStack, 4));
        for i = 1:size(imStack, 4)
            [pixelResponses(:, :, i), a, b] = getRoiPixels(squeeze(imStack(:,:,:,i)), L, roiID);
        end
        return
    end

    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x*y, t]);

    [a, b] = find(L == roiID);
    L = L(:);

    pixelResponses = imStack(L == roiID, :);
