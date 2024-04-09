function clust = performClustering(feat, varargin)
%
% History:
%   30Nov2021 - SSP - Added AIC output option, verbose output

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'maxClust', 25, @isnumeric);
    addParameter(ip, 'minClust', 1, @isnumeric);
    addParameter(ip, 'maxIter', 500, @isnumeric);
    addParameter(ip, 'initReplicates', 20, @isnumeric);
    addParameter(ip, 'finalReplicates', 20, @isnumeric);
    addParameter(ip, 'regularize', 1e-5, @isnumeric);
    addParameter(ip, 'covType', 'diagonal', @ischar);
    addParameter(ip, 'infoCriteria', 'BIC', @(x) ismember(x, {'AIC', 'BIC'}));
    parse(ip, varargin{:});
    p = ip.Results;

    % Set random number generator
    rng(0);

    % Fit models with increasing complexity
    bic = zeros(p.maxClust - p.minClust + 1, 1);
    aic = zeros(size(bic));
    opt = statset('MaxIter', p.maxIter);
    nClust = p.minClust : p.maxClust;

    for j = 1:length(nClust)
        gm = gmdistribution.fit(feat, nClust(j),... 
            'Regularize', p.regularize, 'CovType', p.covType,...
            'Options', opt, 'Replicates', p.initReplicates);
        bic(j) = gm.BIC;
        aic(j) = gm.AIC;
        fprintf('\t%d clusters. BIC = %.2f\n', nClust(j), bic(j));
    end

    % Select best model
    if strcmp(p.infoCriteria, 'BIC')
        [~, mc] = min(bic);
    else
        [~, mc] = min(aic);
    end

    % Refit the model with optimal parameters
    fgm = gmdistribution.fit(feat, nClust(mc), ...
        'Regularize', p.regularize, 'CovType', p.covType, ...
        'Options', opt, 'Replicates', p.finalReplicates);
    
    % Return structure
    clust.model = fgm;
    clust.idx = cluster(fgm, feat);
    clust.posterior = posterior(fgm, feat);
    clust.maxPosterior = max(clust.posterior, [], 2);
    clust.nClust = nClust;
    clust.bic = bic;
    clust.aic = aic;
    clust.K = fgm.NComponents;
    clust.nCells = size(feat, 1);

    [~, minBIC] = min(clust.bic); 
    [~, minAIC] = max(clust.aic);
    fprintf('BIC = %u, AIC = %u\n',... 
        minBIC+p.minClust, minAIC+p.minClust);