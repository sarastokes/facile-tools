function T = roiQualityBatch(imStack, rois)
    % ROIQUALITYBATCH
    %
    % Input:
    %   imStack         response [X, Y, T]
    %

    rois = double(rois);
    S = regionprops('table', rois, 'BoundingBox');
    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x * y, t]);

    rois = rois(:);
    roiList = unique(rois);
    roiList(1) = [];

    ax = axes('Parent', figure());
    T = table(0, 0, 0, [0 0], [0 0], {0}, {0}, {0}, ...
        'VariableNames', {'ID', 'Pixels', 'Max', 'X', 'Y', 'Idx', 'RMSE', 'Bright'});

    for i = 1:numel(roiList)
        L = rois;
        roiID = roiList(i);
        idx = find(L == roiID);
        if isempty(idx)
            warning('ROI %u has no pixels!', i);
            continue
        end
        fprintf('Roi %u has %u pixels, ', i, nnz(idx));

        roiSignal = imStack(idx, :);
        bright = mean(roiSignal, 2);
        roiMean = mean(roiSignal);

        offsets = zeros(size(idx));
        for j = 1:numel(idx)
            offsets(j) = rmse(roiSignal(j, :), roiMean);
        end

        fprintf('max RMSE is %.3g\n', max(offsets));

        L(L ~= roiID) = NaN;
        L(L == roiID) = offsets;
        L = reshape(L, [x, y]);

        bBox = S{roiID, :};
        xBound = [bBox(1) - 1.5, bBox(1) + bBox(3) + 2.5];
        yBound = [bBox(2) - 1.5, bBox(2) + bBox(4) + 2.5];

        T = [T; {i, nnz(idx), max(offsets), xBound, yBound, {idx}, {offsets}, {bright}}];
        
        % ax = axes('Parent', figure());
        
        hold(ax, 'off');
        pcolor(L(yBound(1):yBound(2), xBound(1):xBound(2)));
        hold(ax, 'on');
        axis equal tight off;
        title(sprintf('ROI %u', i));
        % colormap(antijet(10));
        colormap(pmkmp(20, 'CubicL'));
        colorbar();
        shading interp;
        % set(ax, 'CLim', [0 0.05]);
        ax.CLim(1) = 0;
        drawnow;
        pause(0.5);
    end
    T(1, :) = [];
