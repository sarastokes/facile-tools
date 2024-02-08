function plotPCs(U, ev, opts)

    arguments
        U                           double
        ev                          double
        opts.X          (1,:)       double                  = 1:size(U, 1);
        opts.numPCs     (1,1)       double {mustBeInteger}  = size(U,2)
        opts.cmap       (:,3)       double                  = [0 0 0]
        opts.ups        (:,2)       double                  = [NaN NaN]
        opts.downs      (:,2)       double                  = [NaN NaN]
        opts.flip       (1,1)       logical                 = false
    end

    if nnz(opts.cmap) == 0
        opts.cmap = pmkmp(opts.numPCs, 'CubicL');
    end

    figure();
    subplot(1,2,1); hold on; grid on;
    for i = 1:opts.numPCs
        if opts.flip
            [s, l] = bounds(U(:,i));
            if abs(s) > l
                U(:,i) = -1 * U(:,i);
            end
        end
        plot(opts.X, U(:,i), 'LineWidth', 1.75, 'Color', opts.cmap(i,:));
    end
    xlabel('Time (sec)');
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

    subplot(1,2,2);
    h = bar(1:opts.numPCs, ev(1:opts.numPCs), 'FaceColor', 'flat');
    h.CData = opts.cmap(1:opts.numPCs,:);
    grid on; hold on;
    text(opts.numPCs + 0.2, 0.9, sprintf('%.2f%%', 100*sum(ev)), ...
        "FontName", "Arial", "FontSize", 8)
    xlabel('Components');
    ylabel('% variance explained');
    ylim([0 1]);
    figPos(gcf, 1, 0.5);

    fprintf('Variance explained = %.2f\n', 100*sum(ev));
