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
%   imStack             video [X Y T]
%   L                   labeled matrix of ROIs [X Y]
%   ID                  which ROI to return pixel responses
%
% History:
%   10Nov2021 - SSP - From roiQuality
% --------------------------------------------------------------------------

    imStack = double(imStack);
    L = double(L);

    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x*y, t]);

    [a, b] = find(L == roiID);
    L = L(:);

    pixelResponses = imStack(L == roiID, :);

