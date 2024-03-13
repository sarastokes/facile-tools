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
    parse(ip, varargin{:});

    nComp = numel(v);
    nNonZero = nnz(b(:,1));

    co = pmkmp(nComp, 'CubicL');
    figure('Name', 'Feature Detection');
    subplot(1, 2, 1); hold on; axis square
    for i = 1:nComp
        if ip.Results.Area
            area(xpts, b(:, i), 'EdgeColor', co(i, :), 'LineWidth', 0.75,...
                'FaceAlpha', 0.1, 'FaceColor', co(i,:));
        else
            plot(xpts, b(:, i), 'Color', co(i, :), 'LineWidth', 0.75);
        end
    end
    title(sprintf('N=%u, F=%u', nComp, nNonZero));
    xlabel('Time (s)');
    ylim([-1, 1]);
    reverseChildOrder(gca);

    subplot(1, 2, 2); hold on; axis square
    superbar(v, 'BarFaceColor', co);
    ylabel('% variance explained');
    title(sprintf('%u features - %.2f% variance', nComp, sum(v)));
    figPos(gcf, 0.9, 0.5);
    drawnow;