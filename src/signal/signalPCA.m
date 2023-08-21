function [components, covariance] = signalPCA(X)
    % MYPCA
    %
    % Inputs:
    %   X       matrix
    %       Each row is a p-dimensional datapoint
    % Outputs:
    %   components      p x p matrix
    %       Each column is one of the PCs, length 1 SD of variance
    %
    % Notes:
    %   NOT COMPLETE!!!
    % ---------------------------------------------------------------------
    
    
    nSamples = size(X, 1);
    nComponents = size(X, 2);
    
    mean_row = mean(X);
    zeroMeanX = X - mean_row;
    
    % Compute covariance
    covariance = (zeroMeanX' * zeroMeanX) / (nSamples - 1);

    % Find principal components of covariance matrix with SVD
    [~, S, V] = svd(zeroMeanX);

    % Extract the square matrix (p x p) of singular values
    S = S(1:nComponents, 1:nComponents);

    % Compute the variance explained by each component
    varianceExplained = (S * S) / (nSamples - 1);

    % Scale the components by the SD (sqrt(var))
    components = V * sqrt(varianceExplained);