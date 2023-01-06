function h = roiOutline(rois, ID, varargin)
% ROIOUTLINE
%
% Description:
%   Draws an outline around a specific ROI and, optionally, zoom in 
%   around the ROI
%
% Syntax:
%   h = roiOutline(rois, ID, varargin)
%
% Inputs:
%   rois        [x,Y]
%       labeled image of ROIs
%   ID          double
%       ROI to outline (if empty, all will be outlined)
%
% Optional key/value inputs:
%   Parent      axis handle (default = gca)
%       Axis to plot the outline
%   Border      double
%       Number of pixels to keep around ROI when zooming in
%       (If left empty, there will be no change in axis limits)
%   Additional inputs are passed to plot for outline creation
%
% Outputs:
%   h           handle to the outline plot
%
% History:
%   07Dec2022 - SSP
% -------------------------------------------------------------------------

    rois = im2double(rois);

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'Parent', gca, @ishandle);
    addParameter(ip, 'Border', 0, @isnumeric);
    parse(ip, varargin{:});

    nPix = ip.Results.Border;
    ax = ip.Results.Parent;
    hold(ax, 'on');
    
    % Isolate the ROI and create the outline
    h = [];
    if isempty(ID)
        B = bwboundaries(rois, 'noholes');
        for i = 1:numel(B)
            boundary = B{i};
            iHandle = plot(ax, boundary(:,2), boundary(:,1),...
                'Tag', 'RoiOutline', ip.Unmatched);
            h = cat(1, h, iHandle);
        end
    else
        for i = 1:numel(ID)
            mask = bsxfun(@eq, rois, ID(i));
            B = bwboundaries(mask, 'noholes');
            boundary = B{1};
            iHandle = plot(ax, boundary(:,2), boundary(:,1),...
                'Tag', sprintf('RoiOutline_%u', ID(i)), ip.Unmatched);
            h = cat(1, h, iHandle);
        end
    end

    % Determine the zoom region
    if nPix > 0 && ~isempty(ID)
        S = regionprops('table', rois, 'BoundingBox');
        bBox = S{ID, :};

        xBound = [bBox(1) - nPix - 0.5, bBox(1) + bBox(3) + nPix + 0.5];
        yBound = [bBox(2) - nPix - 0.5, bBox(2) + bBox(4) + nPix + 0.5];

        xlim(ax, xBound);
        ylim(ax, yBound);
    end

