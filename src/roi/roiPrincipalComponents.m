function [U, ev] = roiPrincipalComponents(A, N)
    % ROIPRINCIPALCOMPONENTS
    % 
    % Description:
    %   Use SVD to get principal components of ROI responses
    % 
    % Syntax:
    %   T = stimOnsetOffset(A, onsetWindow, offsetWindow, bkgdWindow)
    %
    % Inputs:
    %   A       N x T matrix
    %   N       Number of principal components to return (optional)
    %
    % Outputs:
    %   U       SVD U matrix
    %   ev      Explained variance for each component
    %
    % History:
    %   06Nov2020 - SSP
    % ---------------------------------------------------------------------

    % zero mean
    A = A - ones(size(A, 1), 1) * mean(A);

    [U, S, ~] = svd(A');

    ev = diag(S) .^ 2;
    
    ev = ev ./ sum(ev);

    if nargin == 2
        U = U(:, 1:N);
        ev = ev(1:N);
    end