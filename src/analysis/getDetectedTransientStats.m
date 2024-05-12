function getDetectedTransientStats(peakFrames, peakHeight, sampleRate)

    peakTime = peakFrames/sampleRate*1000;  % ms

    peakInterval = diff(peakTime, [], 2); 
    outlierIdx = isoutlier(peakInterval);
    peakInterval(outlierIdx) = [];
    fprintf('Removed %u outliers from n = %u\n', nnz(outlierIdx), numel(outlierIdx));

    peakHeightMean = mean(peakHeight, "all");
    peakHeightSD = std(peakHeight, [], "all");
    demoCutoffs = [-0.5, -0.25, 0];
    %peakSNR = (peakHeight-peakHeightMean) / peakHeightSD;


    [yCDF, xCDF] = ecdf(peakHeight);
    [iyCDF, ixCDF] = ecdf(peakInterval);

    co = colororder('sail');

    figure(); 
    ax = subplot(1,2,1); hold on;
    histogram(peakHeight, "BinWidth", 0.025);
    plot(xCDF, ax.YLim(2) * yCDF,...
         "Color", co(3,:), "LineWidth", 1, "LineStyle", "--");
    ax.XLim(1) = 0;ax.YLim(1) = 0; grid on;
    for i = 1:numel(demoCutoffs)
        h = plot((peakHeightMean - (demoCutoffs(i)*peakHeightSD))*[1 1], ax.YLim,...
            "Color", co(2,:), "LineWidth", 0.75);
        uistack(h, "bottom");
    end
    xlabel('Peak Height (dF/F)'); ylabel('Number of Peaks');
    title(sprintf('Avg Height = %.2f (n = %u)',... 
        mean(peakHeight(:)), numel(peakHeight)));
    

    ax = subplot(1,2,2); hold on;
    histogram(peakInterval, "BinWidth", 40);
    xregion(ax, 0, 40, "FaceAlpha", 0.3);
    plot(ixCDF, ax.YLim(2) * iyCDF,... 
        "Color", co(3,:), "LineWidth", 1, "LineStyle", "--");
    xlabel('Inter-Transient Interval (ms)'); ylabel('Number Of Peaks');
    title(sprintf('Avg Interval = %.2f', mean(peakInterval(:))));
    ax.XLim(1) = 0; ax.YLim(1) = 0; grid on;
