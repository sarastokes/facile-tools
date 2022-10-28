function [regions, L, numRois] = roiImportImageJ(filePath, imSize)
    % ROIIMPORTIMAGEJ
    %
    % Description:
    %   Wrapper for ImageJ ROI import functions with improvements to
    %   polygon ROI processing
    %
    % Syntax:
    %   [regions, L] = roiImportImageJ(filePath, imSize)
    %
    % Inputs:
    %   filePath    char
    %       Location and name of .roi or .zip file(s)
    %   imSize      vector [1 x 2]
    %       Image X and Y dimensions
    %
    % See also:
    %   ReadImageJROI, ROIs2Regions
    %
    % History:
    %   06Nov2020 - SSP
    %   07Apr2020 - SSP - Added support for Polygon ROIs
    %   28Sep2021 - SSP - Added numRois output
    % ---------------------------------------------------------------------

    sROI = ReadImageJROI(filePath);

    if strcmp(sROI{1}.strType, 'Polygon')
        regions.Connectivity = 8;
        regions.ImageSize = fliplr(imSize);
        regions.NumObjects = numel(sROI);
        regions.PixelIdxList = {};

        for i = 1:numel(sROI)
            roi = sROI{i};
            mbThisMask = poly2mask(roi.mnCoordinates(:, 1)+1, roi.mnCoordinates(:, 2)+1, imSize(2), imSize(1));
            regions.PixelIdxList{i} = find(mbThisMask);
        end
        L = labelmatrix(regions);
    else

        regions = ROIs2Regions(sROI, imSize);
        L = labelmatrix(regions)';
    end
    
    L = double(L);
    
    numRois = numel(unique(L)) - 1;
