function y = ndindex(x, dim, idx)
% NDINDEX
%
% Description:
%   Indexing a specific dimension in matrix w/ arbitrary number of dimensions
%
% Syntax:
%   y = ndindex(x, dim, idx)
%
% Input:
%   x       matrix, any number of dimensions
%   dim     integer, dimension to index
%   idx     integer, index to use
%       logical array, integers or [start endStop] range where endStop is
%       negative and will be subtracted from "end" (python-like)
%
% See also:
%   window2idx
%
% History:
%   24Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        x
        dim         (1,1)       {mustBeInteger}
        idx
    end

    mustBeLessThanOrEqual(dim, ndims(x));

    if islogical(idx)
        idx = find(idx);
    elseif numel(idx) == 2 && idx(2) < 1
        idx(2) = size(x, dim) - idx(2);
        idx = idx(1):idx(2);
    end

    sz = size(x);
    dimRanges = arrayfun(@(x) 1:x, sz, "UniformOutput", false);
    dimRanges{dim} = idx;
    y = x(dimRanges{:});
