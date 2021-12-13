function offsets = roiQuality(imStack, L, roiID)
    % ROIQUALITY
    % ---------------------------------------------------------------------

    imStack = double(imStack);
    L = double(L);
    S = regionprops('table', L, 'BoundingBox');
    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x*y, t]);

    L = L(:);
    roiList = unique(L);
    roiList(1) = [];

    roiID2 = roiList(roiID);
    idx = find(L == roiID2);
    fprintf('Roi %u has %u pixels, ', roiID, nnz(idx));

    roiSignal = imStack(idx, :);
    roiMean = mean(roiSignal);

    offsets = zeros(size(idx));
    for i = 1:numel(idx)
        offsets(i) = rmse(roiSignal(i, :), roiMean);
    end
    fprintf('max RMSE is %.3g\n', max(offsets));

    L(L ~= roiID2) = NaN;
    L(L == roiID2) = offsets;
    L = reshape(L, [x, y]);

    bBox = S{roiID2, :};
    xBound = [bBox(1) - 1.5, bBox(1) + bBox(3) + 2.5];
    yBound = [bBox(2) - 1.5, bBox(2) + bBox(4) + 2.5];

    ax = axes('Parent', figure()); hold on;
    p = pcolor(L(yBound(1):yBound(2), xBound(1):xBound(2)));
    axis equal tight off;
    title(sprintf('ROI %u', roiID));
    colormap(antijet(10));
    colorbar();
    ax.CLim(1) = 0;
