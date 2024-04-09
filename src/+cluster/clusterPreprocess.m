function [data, avgSignal, QI] = clusterPreprocess(rawData, smoothFac, bounds)
% CLUSTERPREPROCESS
%
% Syntax:
%   [data, avgSignal] = clusterPreprocess(rawData, smoothFac, bounds)
%
% History:
%   08Oct2021 - SSP - Pulled from ClusterFeatures.m
%   07Nov2022 - SSP - Better input parsing, removed nanmean call
%   04Apr2024 - SSP - Added quality index computation
% --------------------------------------------------------------------------

    if nargin < 3
        bounds = [1, size(rawData, 2)];
    end

    if iscell(rawData)
        data = cell(0,1); avgSignal = [];
        for i = 1:numel(rawData)
            [iData, iAvg] = cluster.clusterPreprocess(rawData{i}, smoothFac, bounds);
            data = cat(1, data, iData);
            avgSignal = cat(1, avgSignal, iAvg);
        end
        return
    end

    if isempty(smoothFac)
        smoothFac = 0;
    end

    [nRois, nFrames, nReps] = size(rawData);

    data = zeros(size(rawData));
    avgSignal = zeros(nRois, nFrames);

    for i = 1:nRois
        roiData = squeeze(rawData(i, :, :));
        if smoothFac > 1
            for j = 1:nReps
                roiData(:, j) = mysmooth(roiData(:, j), smoothFac);
            end
        end
        if bounds(1) > 1
            roiData = bsxfun(@minus, roiData,...
                median(roiData(smoothFac+1 : bounds(1), :), 1));
        end
        data(i, :, :) = roiData;
        avgSignal(i, :) = mean(roiData, 2, 'omitnan') / max(abs(mean(roiData, 2, 'omitnan')));
        % TODO: Search and correct for NaNs ?
    end

    QI = qualityIndex(data);
