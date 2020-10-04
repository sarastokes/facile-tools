function roiLabel(rois, ax)
    % ROILABEL
    %
    % Syntax:
    %   roiLabel(rois, ax)
    %
    % Inputs:
    %   rois            structure or 2D matrix
    %       ROIs or output of label matrix
    % Optional inputs:
    %   ax              axes handle (default = new figure)
    %       Axis target for labels
    %
    % See also:
    %   LABELMATRIX, VISLABELS
    %
    % History:
    %   28Aug2020 - SSP
    % ---------------------------------------------------------------------
    
    if isstruct(rois)
        L = labelmatrix(rois);
    else
        L = rois;
    end
    
    if nargin < 2
        ax = axes('Parent', figure());
    end
    hold(ax, 'on');
    
    imagesc(ax, L > 0);
    colormap([0.5 0.5 0.5; 1 1 1]);
    
    stats = regionprops('table', L, 'Extrema');
    try
        for i = 1:numel(stats)
            text(stats{i, 1}, stats{i, 2}, sprintf('%d', i),...
                'Parent', ax,...
                'Clipping', 'on',...
                'Color', 'b');
        end
    catch  % TODO: Will this work for regions, rois dataset too?
        for i = 1:numel(stats)
            xy = stats.Extrema{i};
            text(xy(1, 1), xy(1, 2), sprintf('%d', i),...
                'Parent', ax, 'Clipping', 'on', 'Color', 'b');
        end
    end