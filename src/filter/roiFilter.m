function [regions, rois] = roiFilter(regions, rois, indices)
    % ROIFILTER
    %
    % Description:
    %   Keep only regions/rois indexed as true
    %
    % Syntax:
    %   [regions, rois] = roiFilter(regions, rois, indices)
    %
    % Inputs:
    %   indices     binary vector
    %       1s for regions/rois to keep and 0s to discard
    %
    % See also:
    %   ROISTATFILTER
    %
    % History:
    %   24Aug2020 - SSP
    % ---------------------------------------------------------------------

    numObjects = rois.NumObjects;
    assert(numel(indices) == numObjects,... 
        'Index size must match number of rois!');
    
    regions = regions(indices);
    rois.PixelIdxList = rois.PixelIdxList(indices);
    rois.NumObjects = nnz(indices);

    fprintf('Removed %u of %u objects. %u remain\n',... 
        numObjects - nnz(indices), numObjects, nnz(indices));
