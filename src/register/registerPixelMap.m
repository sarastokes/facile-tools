function [newMap, newRois] = registerPixelMap(reg, map, rois)
% Apply registration to pixel map and, optionally, ROIs
%
% Syntax:
%   [newMap, newRois] = registerPixelMap(reg, map, rois)
%
% Inputs:
%   reg         affine2d
%       Registration object
%   map         X by Y by 1 for luminance or 3 for RGB
%       Pixel map to register
% Optional inputs:
%   rois        X by Y
%       ROIs to register 
%
% Outputs:
%   newMap      registered pixel map
%   newRois     registered ROIs
%
% Examples:
%   load('REG_0817_to_0802.mat')
%   % Register just a pixel map'
%   newMap = registerPixelMap(REG_0817_to_0802, map)
%   % Register a pixel map and the ROIs
%   [newMap, newROIs] = registerPixelMap(REG_0817_to_0802, map, rois)
% -------------------------------------------------------------------------

    movingRefObj = imref2d([size(map, 1), size(map, 2)]);
    
    % Register the ROIs
    if nargin > 2
        newRois = imwarp(rois,...
            movingRefObj, reg.Transformation,...
            'OutputView', reg.SpatialRefObj,...
            'SmoothEdges', true);
    end

    % Register the pixel map
    newMap = zeros(size(map));
    if ndims(map) == 3
        for i = 1:size(map,3)
            newMap(:,:,i) = imwarp(map(:,:,i),...
                movingRefObj, reg.Transformation,...
                'OutputView', reg.SpatialRefObj,...
                'SmoothEdges', true);
        end
    else
        newMap = imwarp(map,...
            movingRefObj, reg.Transformation,...
            'OutputView', reg.SpatialRefObj,...
            'SmoothEdges', true);
    end