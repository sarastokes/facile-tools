function plotQualityIndex(QI)


    figure(); hold on; grid on;
    h = histogram(QI, "BinEdges", 0:0.05:1);
    xlim([0 1]); xlabel("Quality Index"); ylabel("Number of ROIs");
    set(gca, 'XMinorGrid', 'on'); axis square;
    title(sprintf("N = %u ROIs", numel(QI)));
    figPos(gcf, 0.6, 0.6); tightfig(gcf);