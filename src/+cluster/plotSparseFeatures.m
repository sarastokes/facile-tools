function plotSparseFeatures(b, v, xpts, varargin)
%
% Syntax:
%   plotSparseFeatures(b, v, xpts)
%
% Inputs:
%   b       [time x features]
%   v       [1 x features]
% -------------------------------------------------------------------------

    ip = inputParser();
    addParameter(ip, 'Area', false, @islogical);
    addParameter(ip, 'Heatmap', false, @islogical);
    addParameter(ip, 'Ups', [], @isnumeric);
    parse(ip, varargin{:});

    ups = ip.Results.Ups;

    nComp = numel(v);
    nNonZero = nnz(b(:,1));

    co = pmkmp(nComp, 'CubicL');
    figure('Name', 'Sparse Features');
    subplot(1, 2, 1); hold on; axis square;
    if ip.Results.Heatmap
        imagesc(b', 'XData', xpts, 'YData', 1:nComp);
        colormap(rgbmap('red', 'white', 'blue', 256))
        makeColormapSymmetric(gca);
    else
        for i = 1:nComp
            if ip.Results.Area
                area(xpts, b(:, i), ...
                    'EdgeColor', co(i, :), 'LineWidth', 0.75,...
                    'FaceAlpha', 0.1, 'FaceColor', co(i,:));
            else
                plot(xpts, b(:, i), ...
                    'Color', co(i, :), 'LineWidth', 0.75);
            end
        end
    end
    title(sprintf('N=%u, F=%u', nComp, nNonZero));
    xlabel('Time (s)'); roundAxisLimits(gca, "y", true);
    if ~isempty(ups)
        if ~ip.Results.Area && ~ip.Results.Heatmap
            addStimPatch(gca, ups, 'FaceColor', [0.7 0.7 0.7], 'FaceAlpha', 0.3);
        else
            ups = ups(:);
            for i = 1:numel(ups)
                h = plot([ups(i), ups(i)], ylim(), '--', 'Color', [0.1 0.1 0.1]);
                uistack(h, "bottom");
            end
        end
    end

    subplot(1, 2, 2); hold on; axis square
    superbar(v, 'BarFaceColor', co);
    ylabel('% variance explained');
    title(sprintf('%u features - %.2f% variance', nComp, sum(v)));
    figPos(gcf, 0.9, 0.5);
    drawnow;