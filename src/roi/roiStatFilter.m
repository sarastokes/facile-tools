function [regions, rois] = roiStatFilter(regions, rois, statName, fcn)
    % ROISTATFILTER
    %
    % Description:
    %   Filter regions and rois by a regionprops statistic
    %
    % Syntax: 
    %   [regions, rois] = roiStatFilter(regions, rois, statName, fcn)
    %
    %
    % Example:
    %   [regions, rois] = roiStatFilter(regions, rois, 'Area', @(x) x < 80)
    %
    % See also:
    %   RUNPLOTMSER, REGIONPROPS
    %
    % History:
    %    8Aug2020 - SSP - Replaces roiSubset.m
    % ---------------------------------------------------------------------

    numObjects = rois.NumObjects;
    stats = regionprops('table', rois, statName);
    stats = stats{:, 1};

    ind = fcn(stats);

    regions = regions(ind);
    rois.PixelIdxList = rois.PixelIdxList(ind);
    rois.NumObjects = nnz(ind);

    fprintf('Removed %u of %u objects. %u remain\n',... 
        numObjects - nnz(ind), numObjects, nnz(ind));
