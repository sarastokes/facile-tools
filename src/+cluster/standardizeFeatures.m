function f2 = standardizeFeatures(f)
% STANDARDIZEFEATURES
%
% Description:
%   Standardize each feature separately
%
% Syntax:
%   f2 = standardizeFeatures(f)
%
% Input:
%   f       Feature matrix [features x samples]
%
% Output:
%   Standardized feature matrix
%
% History:
%   03Dec2021 - SSP
%   03Apr2024 - SSP - Support for column vectors of samples
% -------------------------------------------------------------------------

    if iscolumn(f)
        f2 = zscore(f, [], 1);
    else
        f2 = zscore(f, [], 2);
    end