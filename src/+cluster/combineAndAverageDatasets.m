function [out, exptIdx, roiIdx, nReps] = combineAndAverageDatasets(dset1, dset2, varargin)
% COMBINEANDAVERAGEDATASETS
%
% Description:
%   Convenience methods to save a few lines of code. Concatenated datasets
%   along the first dimension, averaging if needed and cropping extra
%   frames. A warning will be thrown if frames are cropped so it can be
%   confirmed it is reasonable (i.e., a few extra frames).
%
% Syntax:
%   out = cluster.combineAndAverageDatasets(dset1, dset2)
%
% History:
%   03Apr2024 - SSP
% -------------------------------------------------------------------------

    if nargin > 2
        [out, exptIdx, roiIdx, nReps] = cluster.combineAndAverageDatasets(dset1, dset2);
        for i = 1:numel(varargin)
            iDset = varargin{i};
            out = cluster.combineAndAverageDatasets(out, iDset);
            nReps = cat(2, nReps, size(iDset,3));
            exptIdx = [exptIdx; max(exptIdx)+ones(size(iDset,1),1)]; %#ok<AGROW>
            roiIdx = [roiIdx; (1:size(iDset,1))']; %#ok<AGROW>
        end
        return
    end

    nReps = [size(dset1, 3), size(dset2, 3)];
    if ndims(dset1) == 3
        dset1 = mean(dset1, 3);
    end
    if ndims(dset2) == 3
        dset2 = mean(dset2, 3);
    end

    roiIdx = [1:size(dset1, 1), 1:size(dset2, 1)]';
    exptIdx = [ones(size(dset1, 1),1); 1+ones(size(dset2, 1),1)];

    N1 = size(dset1, 2);
    N2 = size(dset2, 2);

    if N1 == N2
        out = cat(1, dset1, dset2);
    elseif N1 > N2
        warning('Removing %u frames from dataset 1', N1 - N2);
        out = cat(1, dset1(:,1:N2), dset2);
    elseif N2 > N1
        warning('Removing %u frames from dataset 2', N2 - N1);
        out = cat(1, dset1, dset2(:, 1:N1));
    end

