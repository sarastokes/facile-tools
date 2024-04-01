function signals = roiEWF(imStack, roiMask)
% ROIEWF
%
% Description:
%   Event-weighted fluorescence trace for photon-starved calcium imaging
%
% Syntax:
%   signals = roiEWF(imStack, roiMask, varargin)
%
% History:
%   25Mar2024 - SSP
% -------------------------------------------------------------------------

    arguments
        imStack         (:,:,:)     {mustBeNumeric}
        roiMask         (:,:)       double
    end

    roiList = unique(roiMask(:));
    roiList(roiList == 0) = [];
    numROIs = numel(roiList);
    numFrames = size(imStack, 3);

    signals = zeros(numROIs, numFrames);
    for i = 1:numROIs
        pix = getRoiPixels(imStack, roiMask, i);
        signals(i,:) = sum(pix, 1)./sum(pix>0, 1);
    end
    signals(isnan(signals)) = 0;

    