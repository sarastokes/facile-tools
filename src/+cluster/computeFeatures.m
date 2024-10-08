function [f, b, v, vv] = computeFeatures(X, nComp, nNonZero, opts)
% COMPUTEFEATURES
%
% Syntax:
%   [f, b, v] = computeFeatures(X, nComp, nNonZero, varargin)
%
% X = response matrix of N by T (neurons by time)
% -------------------------------------------------------------------------

    arguments
        X
        nComp               (1,1)       {mustBeInteger}
        nNonZero            (1,1)       {mustBeInteger}
        opts.MaxSteps       (1,1)       {mustBeInteger} = 300
        opts.ConvCriterion  (1,1)                       = 1e-9
        opts.Center         (1,1)       logical         = false
        opts.Verbose        (1,1)       logical         = false
    end

    assert(exist('spca', 'file') > 0,...
        'computeFeatures: sparse pca not on path!');

    if opts.Center
        X = center(X);
    end

    [b, v] = spca(X, [], nComp, Inf, -nNonZero, opts.MaxSteps, ...
        opts.ConvCriterion, opts.Verbose);
    vv = cumsum(v(1:20) / sum(v));

    fid = zeros(nComp, 1);
    for i = 1:size(b, 2)
        fid(i) = find(abs(diff(b(:, i))) > 0, 1, 'first');
    end
    [~, sidx] = sort(fid, 'ascend');

    b = b(:, sidx);
    f = b' * X;