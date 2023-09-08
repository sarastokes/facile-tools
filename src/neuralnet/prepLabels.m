function rois = prepLabels(rois, savePath)
% PREPLABELS  Prepare labels for training.
%
% Description:
%   Converts ROIs into uint8 and sets them all to 255, writes to disk
%
% Syntax:
%   rois = prepLabels(rois, savePath)
%
% History:
%   30Aug2023 - SSP
% -------------------------------------------------------------------------

    rois(rois>0) = 255;
    rois = uint8(rois);

    if nargin == 2
        imwrite(rois, savePath);
    end