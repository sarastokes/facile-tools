function S = shotNoiseAnalysis(imStack, opts)

    arguments 
        imStack                 (:,:,:)     
        opts.RippleThreshold    (1,1)       uint8 = uint8(0)
        opts.SampleRate         (1,1)       {mustBeInteger} = 25
    end

    S = struct();
    if opts.RippleThreshold > uint8(0)
        threshStack = imStack(:);
        S.ThreshValues = threshStack(threshStack <= opts.RippleThreshold);
        imStack = imStack - opts.RippleThreshold;
        figure(); histogram(S.ThreshValues, "BinWidth", uint8(1));
        ylabel("Number of Pixels"); xlabel("Value (uint8)");
    end

    [x, y, S.nFrames] = size(imStack);
    nSeconds = S.nFrames/opts.SampleRate;
    S.nPixels = x*y;

    S.frameEvents = squeeze(sum(imStack > uint8(0), [1 2]));
    S.pixelEvents = sum(imStack > uint8(0), 3);

    imStack = imStack(:);
    S.eventSizes = imStack(imStack > uint8(0));
    S.numEvents = numel(S.eventSizes);
    fprintf('%u events (%.4f events/pixel/sec)\n', ...
        S.numEvents, S.numEvents/S.nPixels/nSeconds);

    figure(); 
    subplot(3,1,1); hold on;
    histogram(S.eventSizes, "BinWidth", uint8(2));
    ylabel("Number of Events"); xlabel("Value (uint8)");
    title(sprintf('%u events (%.4f events/pixel/sec)\n', ...
        S.numEvents, S.numEvents/S.nPixels/nSeconds));
    subplot(3,1,2); hold on;
    plot(1:S.nFrames, S.frameEvents);
    ylabel("Number of Events");
    xlabel("Frame"); xlim([0 S.nFrames]);
    subplot(3,1,3); hold on;
    histogram(S.frameEvents, "BinWidth", 1);
    xlabel("Number of Events"); ylabel("Number of Frames");
    figPos(gcf, 1, 1.4);
    tightfig(gcf);

    figure(); 
    imagesc(imresize(S.pixelEvents, 2));
    title(sprintf("%u events - %.4f%%", ...
        numel(S.eventSizes), 100*numel(S.eventSizes)/numel(imStack)));
    axis equal tight off;
    colormap(parula(max(S.pixelEvents(:))+1)); colorbar(); 
    set(gca, 'CLim', [0 max(S.pixelEvents(:))]);
    tightfig(gcf);
