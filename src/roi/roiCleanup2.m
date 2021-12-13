function [regions, rois] = roiCleanup2(regions, rois)
    % ROICLEANUP2
    %
    % Description:
    %   Removes all ROIs except those in labelmatrix
    %
    % Syntax:
    %   [regions, rois] = roiCleanup2(regions, rois)
    %
    % Inputs:
    %   regions     region class (e.g. MSERRegions)
    %       Regions from a detection function (e.g. detectMSERRegions)
    %   rois        struct
    %       Connected components from a detection function 
    %
    % See also:
    %   LABELMATRIX, DETECTMSERFEATURES
    %
    % History:
    %   23Aug2020 - SSP
    %   24May2021 - SSP - Renamed after simplified version added
    % ---------------------------------------------------------------------

    L = labelmatrix(rois);

    roiList = unique(L);
    roiList = roiList(2:end);

    numRegions = rois.NumObjects;
    ind = ismember(1:numRegions, roiList);

    regions = regions(ind);
    rois.PixelIdxList = rois.PixelIdxList(roiList);
    rois.NumObjects = nnz(ind);

    fprintf('Removed %u of %u objects. %u remain\n',... 
        numRegions - nnz(ind), numRegions, nnz(ind));

