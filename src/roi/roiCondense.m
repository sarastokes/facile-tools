function rois2 = roiCondense(rois)
    % ROICONDENSE
    %
    % Description:
    %   Make roi numbering consecutive
    %
    % Syntax:
    %   rois2 = roiCondense(rois)
    %
    % Input:
    %   rois       labelmatrix of rois
    %
    % History:
    %   24May2021 - SSP
    % ---------------------------------------------------------------------

    roiList = unique(rois);
    roiList(roiList == 0) = [];

    [m, n] = size(rois);
    rois = rois(:);

    rois2 = zeros(size(rois));
    for i = 1:numel(roiList)
        rois2(rois == roiList(i)) = i;
    end

    rois2 = reshape(rois2, [m, n]);