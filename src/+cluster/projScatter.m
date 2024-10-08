function projScatter(proj)

    nPCs = size(proj, 1);
    pcList = 1:nPCs;
    cmap = slanCM("dense", 20);

    figure('Name', 'PC Projection Scatter'); counter = 0;
    set(gcf, 'DefaultAxesFontSize', 8);
    for i = 1:nPCs
        for j = 1:nPCs
            counter = counter + 1;
            ax = subplot(nPCs, nPCs, counter);
            hold on; grid on;
            if i == j
                histogram(proj(i,:));
                zeroBar(ax, "y");
                xlabel(['PC', num2str(i)]);
                ylabel('Number of ROIs');
                continue
            end
            idx = find(~ismember(pcList, [i j]), 1);
            scatter(proj(i,:), proj(j,:), 6, proj(idx,:), "filled");
            xlabel(['PC' num2str(i)]);
            ylabel(['PC' num2str(j)]);
            roundAxisLimits(ax, "xy", true);
            zeroBar(ax, "xy");
            axis square;
            colormap(cmap);
        end
    end