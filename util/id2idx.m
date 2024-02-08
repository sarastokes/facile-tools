function idx = id2idx(IDs, idxRange)
% ID2IDX  Convert integers to indices
%
% Syntax:
%   idx = id2idx(IDs, idxRange)
%
% History:
%   15Oct2023 - SSP
% -------------------------------------------------------------------------

    arguments
        IDs         double      {mustBeInteger}
        idxRange    double      {mustBeInteger}
    end

    if numel(idxRange) == 1
        idxRange = [1 idxRange];
    end
    idx = false(numel(idxRange(1):idxRange(2)), 1);
    idx(IDs) = true;