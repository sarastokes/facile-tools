function plotProfileXY(imStack)

    [X, Y, T] = size(imStack);
    figure();
    subplot(2,1,1);  hold on; grid on;
    plot(mean(max(imStack, [], 3), 2));
    xlim([1 X]); xticks(0:5:X); xticklabels([]);
    subplot(2,1,2); hold on; grid on;
    plot(mean(max(imStack, [], 3), 1));
    xlim([1 Y]); xticks(0:5:Y); xticklabels([]);
    figPos(gcf, 0.8, 0.5);
