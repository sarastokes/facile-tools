function [Y, loss, params] = performTSNE(feat, clustIDs, opts)
% PERFORMTSNE
%
%
% Resources
%   Kobak & Berens (2019) The art of using t-SNE for single-cell
%       transcriptomics. Nature Communications, 10, 5416
%
% History:
%   09May2024 - SSP
%   28May2024 - SSP - Better defaults, more options
% -------------------------------------------------------------------------

    arguments
        feat                  (:,:)   double
        clustIDs                      {mustBeVector, mustBeInteger}
        opts.DistMetric       (1,1)   string      = "euclidean"
        opts.Standardize      (1,1)   logical     = false
        opts.Exaggeration     (1,1)   double      = 4
        opts.NumPCAComponents (1,1)   double      = 0
        opts.MaxIter          (1,1)   double      = 1200
        % These two properties use are initialized if 0
        opts.Perplexity       (1,1)   double      = 0
        opts.LearnRate        (1,1)   double      = 0
        opts.NumReplicates    (1,1)   double      = 1
        opts.Verbose          (1,1)   {mustBeMember(opts.Verbose, 0:2)} = 0
    end

    if opts.Perplexity == 0
        opts.Perplexity = max([30, ceil(size(feat, 1)/100)]);
    end

    if opts.LearnRate == 0
        opts.LearnRate = max([200, ceil(size(feat, 1)/12)]);
    end
    fprintf('Perplexity = %s, LearnRate = %s, Exaggeration = %s',...
        num2str(opts.Perplexity), num2str(opts.LearnRate), num2str(opts.Exaggeration));

    params = struct("DistMetric", opts.DistMetric,...
        "Standardize", opts.Standardize,...
        "Perplexity", opts.Perplexity,...
        "Exaggeration", opts.Exaggeration,...
        "NumPCAComponents", opts.NumPCAComponents,...
        "MaxIter", opts.MaxIter,...
        "NumReplicates", opts.NumReplicates,...
        "Verbose", opts.Verbose);

    fitOptions = statset("MaxIter", opts.MaxIter,...
        "OutputFcn", @(optimValues, state) logKL(optimValues, state, clustIDs));

    if opts.DistMetric == "tour"
        metrics = ["euclidean", "correlation", "cosine", "chebychev"];
        figure(); ax = arrayfun(@(x) subplot(2,2,x), 1:4);
        figPos(gcf, 1.25, 1.25);
        for i = 1:numel(metrics)
            fprintf("\nMETRIC = %s -----------------\n", metrics(i));
            rng default
            try
                [Y, loss] = tsne(feat,...
                    "Algorithm", "exact",...
                    "Distance", metrics(i),...
                    "Standardize", opts.Standardize,...
                    "Perplexity", opts.Perplexity,...
                    "Exaggeration", opts.Exaggeration,...
                    "LearnRate", opts.LearnRate,...
                    "NumPCAComponents", opts.NumPCAComponents,...
                    "Options", fitOptions,...
                    "Verbose", opts.Verbose);
            catch ME
                if strcmp(ME.identifier,  'stats:pdist:SingularCov')
                    continue
                else
                    rethrow(ME);
                end
            end

            gscatter(ax(i), Y(:,1), Y(:,2), clustIDs, othercolor('Spectral10', max(clustIDs)));
                %pmkmp(max(clustIDs), 'CubicL'));
            title(ax(i), sprintf("%s,%u (%.3f)", metrics(i), opts.Perplexity, loss));
            axis(ax(i), 'equal'); grid(ax(i), 'on'); legend(ax(i), 'off')
        end
        fprintf('\n');
        return
    end

    results = cell(1, opts.NumReplicates);
    losses = zeros(1, opts.NumReplicates);
    if opts.NumReplicates == 1
        rng(42);
    end
    for i = 1:opts.NumReplicates
        [results{i}, losses(i)] = tsne(feat, 'Algorithm', 'exact',...
            "Distance", opts.DistMetric, ...
            "Perplexity", opts.Perplexity,...
            "Exaggeration", opts.Exaggeration,...
            "Standardize", opts.Standardize,...
            "LearnRate", opts.LearnRate,...
            "Options", fitOptions);
    end

    fprintf('Loss: '); 
    if numel(losses) > 1
        printStat(losses);
    else
        fprintf('%.3f\n', losses);
    end

    [~, idx] = min(losses);
    loss = losses(idx);
    Y = results{idx};

    figure('DefaultAxesFontSize', 10); hold on;
    gscatter(Y(:,1), Y(:,2), clustIDs, othercolor('Spectral10', max(clustIDs)));
    clickableLegend("Location", "eastoutside");
    title(sprintf("%s (%.3f)", opts.DistMetric, loss));
    axis equal; grid on;
    xlabel("t-SNE 1"); ylabel("t-SNE 2");
    figPos(gcf, 0.8, 0.8);
end

function stop = logKL(optimValues, state, species)
    persistent h kllog iters stopnow
    switch state
        case 'init'
            stopnow = false;
            kllog = [];
            iters = [];
            h = figure;
            c = uicontrol('Style','pushbutton','String','Stop','Position', ...
                [10 10 50 20],'Callback',@stopme);
        case 'iter'
            kllog = [kllog; optimValues.fval,-log(norm(optimValues.grad))];
            assignin('base','history',kllog)
            iters = [iters; optimValues.iteration];
            if length(iters) > 1
                figure(h)
                subplot(2,1,2)
                plot(iters, kllog, "LineWidth", 1);
                xlabel('Iterations')
                ylabel('Loss and Gradient')
                legend('Divergence','-log(norm(gradient))')
                title('Divergence and -log(norm(gradient))')
                subplot(2,1,1)
                gscatter(optimValues.Y(:,1), optimValues.Y(:,2), species, othercolor('Spectral10', max(species)));
                title('Embedding'); legend('off');
                drawnow
            end
            % Check for increasing KL divergence
            if length(iters) == 99
                if any(diff(kllog) < 0)
                    warning('Divergence increased in initial 99 iterations');
                end
            end
        case 'done'
            % Nothing here
    end

    stop = stopnow;

    function stopme(~,~)
        stopnow = true;
    end
end