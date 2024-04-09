function [avgData, allData, X, QI] = spcaPrep(rawData, opts)
% SPCAPREP
%
% 1. Clip data to specified bounds
% 2. Downsample data, if necessary
% 3. Baseline correct
% 4. Calculate the QI

    arguments
        rawData
        opts.Bounds     (1,2)   {mustBeInteger} = [0 0]
        opts.Clip       (1,2)   {mustBeInteger} = [1 0]
        opts.Downsample (1,1)   {mustBeInteger} = 1
        opts.X          (1,:)   double = 1:size(rawData,2)
        opts.Correct    (1,1)   logical = true
    end

    if iscell(rawData)
        allData = cell(1, numel(rawData));
        avgData = []; QI = [];

        for i = 1:numel(rawData)
            [iAvg, allData{i}, X, iQI] = cluster.spcaPrep(rawData{i},...
                "Bounds", opts.Bounds, "X", opts.X, ...
                "Correct", opts.Correct, "Clip", opts.Clip,... 
                "Downsample", opts.Downsample);
        
            avgData = cat(1, avgData, iAvg);
            QI = cat(1, QI, iQI);
        end
        return
    end

    bkgd = opts.Bounds;
    if ~isequal(bkgd, [0 0])
        allData = bsxfun(@minus, rawData, median(rawData(:, bkgd(1):bkgd(2), :), 2, "omitmissing"));
    else
        allData = rawData;
    end
    
    % 
    % numROIs = size(allData,1);
    % avgData = zeros(size(allData, [1 2]));
    if opts.Correct
        if ndims(allData) == 3
            avgData = mean(allData, 3, "omitmissing"); 
            for i = 1:size(avgData, 1)
                avgData(i,:) = avgData(i,:) / max(abs(avgData(i,:)), [], "omitmissing");
            end
        else
            avgData = allData ./ max(abs(allData), [], 2);
        end
        % for i = 1:numROIs
        %     roiData = squeeze(allData(i,:,:));
        %     if ndims(allData) == 3
        %         avgData(i,:) = mean(roiData, 2, 'omitmissing') ...
        %             / max(abs(mean(roiData, 2, 'omitmissing')));
        %     else
        %         roiData = bsxfun(@minus, roiData, median(roiData, 2, "omitmissing"));
        %         avgData(i,:) = roiData;
        %     end
        %     allData(i,:,:) = roiData;
        %     if nnz(isnan(avgData(i,:))) > 0
        %         warning('NaN values for ROI %u', i);
        %     end
        %     % TODO: Search and correct for NaNs?
        % end
    else
        if ndims(allData) == 3
            avgData =  mean(allData, 3);
        else
            avgData = allData;
        end
    end

    if ~isequal(opts.Clip, [1 0])
        [allData, X] = timeClip(allData, opts.Clip, 2, opts.X);
        [avgData, X] = timeClip(avgData, opts.Clip, 2, opts.X);
    else
        allData = rawData; X = opts.X;
    end


    % TODO: Assumes 25 Hz sampling rate
    if opts.Downsample > 1
        allData = roiDownsample(allData, opts.Downsample, "mean", "X", X);
        [avgData, X] = roiDownsample(avgData, opts.Downsample, "mean", "X", X);
    end



    QI = qualityIndex(allData);