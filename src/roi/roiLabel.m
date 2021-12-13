function ax = roiLabel(rois, varargin)
    % ROILABEL
    %
    % Description:
    %   Show ROIs with their IDs labeled
    %
    % Syntax:
    %   ax = roiLabel(rois)
    %
    % Inputs:
    %   rois            structure or 2D matrix
    %       ROIs or label matrix
    % Optional key/value inputs:
    %   Parent          axes handle (default = new figure)
    %       Axis target for labels
    %   Index           vector
    %       ID(s) of rois to color green
    %   Index2          vector
    %       ID(s) of rois to color red
    %
    % See also:
    %   LABELMATRIX, VISLABELS
    %
    % History:
    %   28Aug2020 - SSP
    %   04Oct2020 - SSP - Added option to color rois (for good/bad cells)
    %   12Nov2020 - SSP - Flipped roi map to remain correct w/ imagesc
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Parent', axes('Parent', figure()), @ishandle);
    addParameter(ip, 'Color', [0.6, 1, 0.7], @isnumeric);
    addParameter(ip, 'Index', [], @isnumeric);
    addParameter(ip, 'Index2', [], @isnumeric);
    parse(ip, varargin{:});

    ax = ip.Results.Parent;
    hold(ax, 'on');
    idx = ip.Results.Index;
    idx2 = ip.Results.Index2;
    
    if isstruct(rois)
        L = labelmatrix(rois);
    else
        L = rois;
    end
    
    L = flipud(L);
    
    if ~isempty(idx)
        [x, y] = size(L);
        L2 = L(:);
        % Cells flagged to be colored in
        L2(ismember(L, idx)) = 0.5;
        if ~isempty(idx2)
            L2(ismember(L, idx2)) = 1.5;
        end
        % Not flagged and not background
        L2(~ismember(L2, [0, 0.5, 1.5])) = 1;
        L2 = reshape(L2, [x, y]);
        
        imagesc(ax, L2);
        if ~isempty(idx2)
            colormap([0.75 0.75 0.75; ip.Results.Color; 1 1 1; 1, 0.6, 0.7]);
        else
            colormap([0.75 0.75 0.75; ip.Results.Color; 1 1 1]);
        end
            
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
                'FontSize', 5, 'FontName', 'Arial');
        end
    catch
        for i = 1:numel(stats)
            text(stats{i, 1}, stats{i, 2}, sprintf('%d', i),...
                'Parent', ax, 'Clipping', 'on', 'Color', 'b');
        end
    end
    
    axis(ax, 'equal', 'tight', 'off');