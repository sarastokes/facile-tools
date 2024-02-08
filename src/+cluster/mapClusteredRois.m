function newMap = mapClusteredRois(clustIdx, roiIDs, roiMap, plotFlag)

    if nargin < 4
        plotFlag = false;
    end

    [x, y] = size(roiMap);
    L = roiMap(:);
    L(~ismember(L, roiIDs)) = 0;

    for i = 1:numel(roiIDs)
        L(L == roiIDs(i)) = clustIdx(i);
    end

    newMap = reshape(L, [x, y]);

    if plotFlag
        figure();
        imagesc(newMap);
        colormap([0.98 0.98 0.98; pmkmp(max(clustIdx), 'CubicL')]);
        axis equal tight;
        set(gca, 'XTick', [], 'YTick', []);
        tightfig(gcf);
    end