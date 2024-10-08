function plotPcaAndProj(U, ev, proj, opts)

    arguments
        U                           double
        ev                          double
        proj                        double
        opts.X          (1,:)       double                  = 1:size(U, 1);
        opts.numPCs     (1,1)       double {mustBeInteger}  = size(U,2)
        opts.cmap       (:,3)       double                  = [0 0 0]
        opts.ups        (:,2)       double                  = [NaN NaN]
        opts.downs      (:,2)       double                  = [NaN NaN]
        opts.flip       (1,1)       logical                 = false
    end

    if nnz(opts.cmap) == 0
        %opts.cmap = pmkmp(opts.numPCs, 'CubicL');
        opts.cmap = othercolor('Spectral10', opts.numPCs);
    end

    fh = figure(); colororder('sail');
    fh.Position(3) = 1.1*fh.Position(3);
    fh.Position(4) = 0.5*fh.Position(4);
    set(fh, 'DefaultAxesFontSize', 10);

    subplot(1, 3, 1); hold on; grid on;
    for i = 1:opts.numPCs
        if opts.flip
            [s, l] = bounds(U(:,i));
            if abs(s) > l
                U(:,i) = -1 * U(:,i);
            end
        end
        plot(opts.X, U(:,i), 'LineWidth', 1.75, 'Color', opts.cmap(i,:));
    end
    xlabel('Time (sec)'); xlim([0, max(opts.X)]);
    addZeroBarIfNeeded(gca);
    reverseChildOrder(gca);

    if all(~isnan(opts.ups))
        for i = 1:size(opts.ups, 1)
            xregion(opts.ups(i,1), opts.ups(i,2), ...
                "FaceColor", [0.75 0.75 0.75], "FaceAlpha", 0.3);
        end
    end
    if all(~isnan(opts.downs))
        for i = 1:size(opts.downs, 1)
            xregion(opts.downs(i,1), opts.downs(i,2),...
                "FaceColor", [0.45 0.45 0.45], "FaceAlpha", 0.3);
        end
    end

    subplot(1,3,2); hold on;
    h = bar(1:opts.numPCs, ev(1:opts.numPCs), 'FaceColor', 'flat');
    h.CData = opts.cmap(1:opts.numPCs,:);
    grid on; hold on;
    text(opts.numPCs + 0.5, 0.93, sprintf('%.2f%%', 100*sum(ev)), ...
        "FontName", "Arial", "FontSize", 10, "HorizontalAlignment", "right");
    xlabel('Components'); ylabel('% variance explained');
    xlim([0.2, opts.numPCs+0.8]); ylim([0 1]); xticks(1:opts.numPCs);

    subplot(1,3,3); hold on;
    scatter(proj(1,:), proj(2,:), 7, "filled");
    scatter(proj(1,:), proj(2,:), 7, proj(3,:), "filled");
    xlabel('PC1'); ylabel('PC2'); grid on;
    xlim(max(abs(xlim))*[-1 1]); ylim(max(abs(ylim))*[-1 1]);
    makeColormapSymmetric(gca);
    zeroBar(gca, "xy");
    set(gca,  'Box', 'on', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
    colormap(slanCM('dense', 256));

    fprintf('Variance explained = %.2f\n', 100*sum(ev));
