function [U, ev, proj, est] = roiPrincipalComponents(A0, N)
% ROIPRINCIPALCOMPONENTS
%
% Description:
%   Use SVD to get principal components of ROI responses
%
% Syntax:
%   [U, ev, proj] = roiPrincipalComponents(A, N)
%
% Inputs:
%   A       N x T matrix
%   N       Number of principal components to return (optional)
%
% Outputs:
%   U       SVD U matrix
%   ev      Explained variance for each component
%   proj    Projection onto low rank basis
%
% History:
%   06Nov2020 - SSP
% ---------------------------------------------------------------------

    A = A0 ./ max(abs(A0), [], 2);

    [U, S, V] = svd(A');

    ev = diag(S) .^ 2;
    ev = ev ./ sum(ev);

    if nargin == 2
        U = U(:, 1:N);
        ev = ev(1:N);
    end

    proj = U' * A';

    recon = proj * V';
    recon = recon + ones(N,1) * mean(A0,2)';
    est = recon' * -U';