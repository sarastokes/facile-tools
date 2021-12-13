function f = standardizeFeatures(f)
    % STANDARDIZEFEATURES
    %
    % Description:
    %   Standardize each feature separately
    %
    % Syntax:
    %   f = standardizeFeatures(f)
    %
    % Input:
    %   f       Feature matrix [features x samples]
    %
    % Output:
    %   Standardized feature matrix
    %
    % History:
    %   03Dec2021 - SSP
    % ---------------------------------------------------------------------

    f = zscore(f, [], 2);