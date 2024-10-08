function [basis, m, s, v] = computePcaFeatures(data)

    [coeff, ~, v] = pca(data);
    basis = coeff(:, 1:min(20, size(coeff, 2)));
    m = mean(data, 1);
    s = std(data, [], 1);

    v = cumsum(v(1:20))/sum(v);