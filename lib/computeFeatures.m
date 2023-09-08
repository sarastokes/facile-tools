function [f, b, v] = computeFeatures(X, nComp, nNonZero)
    % data = computeFeatures
    %
    % X = response matrix of T by N (time by neurons)
    
    if nargin < 2
        nComp = 20;
    end

    if nargin < 3
        nNonZero = 10;
    end

    assert(exist('spca') > 0,...
        'computeFeatures: sparse pca not on path!');

    [b, v] = spca(X', [], nComp, Inf, -nNonZero);
    % v = cumsum(v(1:20) / sum(v));

    fid = zeros(nComp, 1);
    for i = 1:size(b, 2)
        fid(i) = find(abs(diff(b(:, i))) > 0, 1, 'first');
    end
    [~, sidx] = sort(fid, 'ascend');

    b = b(:, sidx);
    f = b' * X;