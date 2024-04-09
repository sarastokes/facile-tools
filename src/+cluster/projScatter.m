function projScatter(proj)

    nPCs = size(proj, 1);
    pcList = 1:nPCs;
    cmap = slanCM("dense", 20);

    figure('Name', 'PC Projection Scatter'); counter = 0;
    for i = 1:nPCs
        for j = 1:nPCs
            counter = counter + 1;
            idx = find(~ismember(pcList, [i j]), 1);
            ax = subplot(nPCs, nPCs, counter);
            hold on; grid on;
            scatter(proj(i,:), proj(j,:), 6, proj(idx,:), "filled");
            xlabel(['PC' num2str(i)]);
            ylabel(['PC' num2str(j)]);
            roundAxisLimits(ax, "xy", true);
            zeroBar(ax, "xy");
            axis square;
            colormap(cmap);
        end
    end