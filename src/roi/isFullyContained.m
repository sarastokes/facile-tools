function tf = isFullyContained(roiBox, patchBox, nHalo)
% ISFULLYCONTAINED
%
% Syntax:
%   tf = isFullyContained(roiBox, patchBox, nHalo)
%
% Inputs:
%   roiBox      double [x y width height]
%       ROI bounding boxes
%   patchBox    double [x y width height]
%       Box of patch to crop from the image
%   nHalo       double [1, 1]
%       Number of pixels around an ROI to exclude
%
% History:
%   29Aug2023 - SSP
% -------------------------------------------------------------------------

    arguments
        roiBox      (:,4)   double
        patchBox    (1,4)   double
        nHalo       (1,1) {mustBePositive, mustBeInteger} = 0
    end

    xMinRoi = roiBox(1) - nHalo;
    xMaxRoi = roiBox(1) + roiBox(3) + nHalo;
    yMinRoi = roiBox(2) - nHalo;
    yMaxRoi = roiBox(2) + roiBox(4) + nHalo;

    xMinPatch = patchBox(1);
    xMaxPatch = patchBox(1) + patchBox(3);
    yMinPatch = patchBox(2);
    yMaxPatch = patchBox(2) + patchBox(4);

    % Check if all corners of the bounding box are within the patch
    if xMinRoi >= xMinPatch && yMinRoi >= yMinPatch && xMaxRoi <= xMaxPatch && yMaxRoi <= yMaxPatch
        tf = true;
    else
        tf = false;
    end
end