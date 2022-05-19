function [data, avgSignal] = clusterPreprocess(rawData, smoothFac, bounds)
    % CLUSTERPREPROCESS
    %
    % Syntax:
    %   [data, avgSignal] = clusterPreprocess(rawData, smoothFac, bounds)
    %
    % History:
    %   08Oct2021 - SSP - Pulled from ClusterFeatures.m
    % ---------------------------------------------------------------------

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
        avgSignal(i, :) = nanmean(roiData, 2) / max(abs(nanmean(roiData, 2)));  
        % TODO: Search and correct for NaNs ?
    end
    