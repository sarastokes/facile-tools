function [out, idx, minFlag] = maxormin(data, dim, opts)
% MAXORMIN
%
% Syntax:
%   [out, idx, minFlag] = maxormin(data, dim)
%
% History:
%   07Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        data
        dim         (1,1)       {mustBeInteger}
        opts.Reverse    (1,1)   logical         = false
    end

    [maxValues, maxIdx] = max(data, [], dim);
    [minValues, minIdx] = min(data, [], dim);

    minFlag = abs(minValues) > abs(maxValues);
    if opts.Reverse
        out = minValues;
        out(minFlag) = maxValues(minFlag);
    else
        out = maxValues;
        out(minFlag) = minValues(minFlag);
    end

    out = squeeze(out);

    if nargout > 1
        if opts.Reverse
            idx = maxIdx;
            idx(minFlag) = minIdx(minFlag);
        else
            idx = maxIdx;
            idx(minFlag) = minIdx(minFlag);
        end
        idx = squeeze(idx);
    end