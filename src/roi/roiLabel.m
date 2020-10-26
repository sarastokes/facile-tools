function roiLabel(rois, varargin)
    % ROILABEL
    %
    % Syntax:
    %   roiLabel(rois)
    %
    % Inputs:
    %   rois            structure or 2D matrix
    %       ROIs or label matrix
    % Optional key/value inputs:
    %   Parent          axes handle (default = new figure)
    %       Axis target for labels
    %   Index           vector
    %       ID(s) of rois to color
    %
    % See also:
    %   LABELMATRIX, VISLABELS
    %
    % History:
    %   28Aug2020 - SSP
    %   04Oct2020 - SSP - Added option to color rois (for good/bad cells)
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Parent', axes('Parent', figure()), @ishandle)
    addParameter(ip, 'Index', [], @isnumeric);
    parse(ip, varargin{:});

    ax = ip.Results.Parent;
    hold(ax, 'on');
    idx = ip.Results.Index;
    
    if isstruct(rois)
        L = labelmatrix(rois);
    else
        L = rois;
    end
    
    if ~isempty(idx)
        [x, y] = size(L);
        L2 = L(:);
        % Cells flagged to be colored in
        L2(ismember(L, idx)) = 0.5;
        % Not flagged and not background
        L2(~ismember(L2, [0, 0.5])) = 1;
        L2 = reshape(L2, [x, y]);
        
        imagesc(ax, L2);
        colormap([0.75 0.75 0.75; 0.6 1 0.7; 1 1 1]);
    else
        imagesc(ax, L > 0);
        colormap([0.75 0.75 0.75; 1 1 1]);
    end

    stats = regionprops('table', L, 'Extrema');
    try  % TODO: Will this work for regions, rois dataset too?
        for i = 1:numel(stats)
            xy = stats.Extrema{i};
            text(xy(1, 1), xy(1, 2), sprintf('%d', i),...
                'Parent', ax, 'Clipping', 'on', 'Color', 'b',...
                'FontSize', 8, 'FontName', 'Arial');
        end
    catch
        for i = 1:numel(stats)
            text(stats{i, 1}, stats{i, 2}, sprintf('%d', i),...
                'Parent', ax, 'Clipping', 'on', 'Color', 'b');
        end
    end
    
    axis(ax, 'equal', 'tight', 'off');