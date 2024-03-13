function out = featureProject(data, features)
% FEATUREPROJECT
%
% Description:
%   Project data onto a set of features
%
% Syntax:
%   out = cluster.featureProject(data, features)
%
% Input:
%   data        double, matrix (N x T)
%       Matrix of N responses
%   features    double, matrix (T, F)
%       Matrix of F features
%
% Output:
%   out         double, matrix (N x F)
%       Loadings for each feature
%
% Example:
%   [f, b, v] = computeFeatures(data', varargin)
%   out = cluster.featureProject(data, b)
%
% History:
%   29Feb2024 - SSP
% --------------------------------------------------------------------------

    nTime = size(data, 2);

    if size(features, 1) ~= nTime
        features = features';
    end
    if size(features, 1) ~= nTime
        error('projectOntoFeatures:DimensionMismatch',...
            'The time dimension of the data and the features must match.');
    end

    out = data * features;