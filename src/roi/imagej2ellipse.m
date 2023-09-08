function EL = imagej2ellipse(iROI)
%IMAGEJ2ELLIPSE
%
% History:
%   06Sept2023 - SSP
% -------------------------------------------------------------------------

    xy = [iROI.vnRectBounds(1)+iROI.vnRectBounds(3), ...
          iROI.vnRectBounds(2) + iROI.vnRectBounds(4)] / 2;
    fA = abs(iROI.vnRectBounds(3) - xy(1)) + 1;
    fB = abs(iROI.vnRectBounds(4) - xy(2)) + 1;
    EL = images.roi.Ellipse('Center', xy, 'SemiAxes', [fA, fB]);
