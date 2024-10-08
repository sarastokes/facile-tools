function roiIDs = findRoisWithNanValues(data)
% FINDROISWITHNANVALUES
%
% Syntax:
%   roiIDs = findRoisWithNanValues(data)
%
% History:
%   28May2024 - SSP
% --------------------------------------------------------------------------

    roiIDs = [];
    for i = 1:size(data, 1)
        idx = isnan(data(i,:));
        if nnz(idx) > 0
            roiIDs = [roiIDs, i];
            fprintf('Roi %d has %d NaN values\n', i, nnz(idx));
        end
    end