function data = restoreBlankToDataset(data, imagingSide)
% RESTOREBLANKTODATASET
%
% Syntax:
%   data = restoreBlankToDataset(data, imagingSide)
%
% History:
%   26Oct2021 - SSP
% -------------------------------------------------------------------------

    switch imagingSide
        case 'left'
            data = [data; zeros(size(data), 'like', data)];
        case 'right'
            data = [zeros(size(data), 'like', data), data];
        otherwise
            error('restoreBlankToDataset: unrecognized imaging side: %s', imagingSide);
    end
