function [regions, rois] = roiRemove(regions, rois, roiIndex)
    % ROIREMOVE
    %
    % Syntax:
    %   [regions, rois] = roiRemove(regions, rois, roiIndex)
    %
    % History:
    %   23Aug2020 - SSP
    % ---------------------------------------------------------------------
    regions(roiIndex) = [];
    rois.PixelIdxList(roiIndex) = [];
    rois.NumObjects = rois.NumObjects - 1;


