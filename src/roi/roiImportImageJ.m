function [regions, L] = roiImportImageJ(filePath, imSize)
    % ROIIMPORTIMAGEJ
    %
    % Description:
    %   Wrapper for ImageJ ROI import functions with duplicate ROI cleanup
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
    % ---------------------------------------------------------------------

    sROI = ReadImageJROI(filePath);
    
    % Look for duplicates
    roiNames = cellfun(@(x) string(x.strName), sROI);

    % [x, ind] = unique(roiNames, 'first');
    % sROI = sROI(ind);

    regions = ROIs2Regions(sROI, imSize);
    L = labelmatrix(regions)';
