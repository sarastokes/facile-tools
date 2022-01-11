function pixPlotOnsetOffset(imStack, rois, roiID, onsetWindow, offsetWindow, bkgdWindow)
    % PIXPLOTONSETOFFSET

    onsetPts = window2idx(onsetWindow);
    offsetPts = window2idx(offsetWindow);
    bkgdPts = window2idx(bkgdWindow);
    
    [pix, a, b] = getRoiPixels(imStack, rois, roiID);

    onMean = mean(pix(:, onsetPts), 2) - mean(pix(:, bkgdPts), 2);
    offMean = mean(pix(:, onsetPts), 2) - mean(pix(:, bkgdPts), 2);
    
    S = regionprops('table', rois, 'BoundingBox');
    bBox = S{roiID, :};
    xBound = [bBox(1) - 0.5, bBox(1) + bBox(3) + 1.5];
    yBound = [bBox(2) - 0.5, bBox(2) + bBox(4) + 1.5];
        
    Lon = zeros(size(rois));
    Lon = Lon(:); 
    Lon(rois ~= roiID) = NaN;
    Loff = Lon;
    Lon(rois == roiID) = onMean;
    Loff(rois == roiID) = offMean;
    Lon = reshape(Lon, size(rois));
    Loff = reshape(Loff, size(rois));


    figure('Name', sprintf('%u - Pixel Onset Offset', roiID)); 
    subplot(1,2,1); hold on;
    title(sprintf('Onset - %u', roiID));
    pcolor(Lon(yBound(1):yBound(2), xBound(1):xBound(2)));
    axis equal tight off;
    shading interp;

    subplot(1,2,2); hold on;
    title(sprintf('Offset - %u', roiID));
    pcolor(Loff(yBound(1):yBound(2), xBound(1):xBound(2)));
    axis equal tight off;
    shading interp;

    makeColormapSymmetric();
    colormap(lbmap(11, 'redblue'))

    tightfig(gcf);
    drawnow;