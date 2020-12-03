function L2 = onsetOffsetMap(L, stat, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Threshold', [], @isnumeric);
    addParameter(ip, 'Title', [], @ischar);
    addParameter(ip, 'FlipCMap', false, @islogical);
    parse(ip, varargin{:});

    threshold = ip.Results.Threshold;

    numROIs = numel(unique(L)) - 1;
    [m, n] = size(L);
    L2 = double(L(:));

    for i = 1:numROIs 
        L2(L2 == i) = stat(i);
    end

    if ~isempty(threshold)
        L2(L2 < threshold & L2 > -threshold) = 0;
    end

    L2 = reshape(L2, [m, n]);

    figure(); imagesc(L2);
    axis equal tight off;
    colorbar('TickDirection', 'out');
    % colormap(bluewhitered(256))
    if ip.Results.FlipCMap
        colormap(flipud(othercolor('BuDRd_18', 17)));
    else
        colormap(othercolor('BuDRd_18', 17));
    end
    % colormap(othercolor('GrMg_16', 15));
    set(gca, 'CLim', [-max(abs(stat)), max(abs(stat))]);

    if ~isempty(ip.Results.Title)
        title(ip.Results.Title);
    end
    
