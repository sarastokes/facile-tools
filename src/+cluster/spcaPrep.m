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
            if i>1 && size(iAvg,2) > size(avgData,2)
                iAvg = iAvg(:,1:size(avgData,2));
            end
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
    
    if opts.Correct
        if ndims(allData) == 3
            avgData = mean(allData, 3, "omitmissing"); 
            for i = 1:size(avgData, 1)
                avgData(i,:) = avgData(i,:) / max(abs(avgData(i,:)), [], "omitmissing");
            end
        else
            avgData = allData ./ max(abs(allData), [], 2);
        end
    else
        if ndims(allData) == 3
            avgData =  mean(allData, 3);
        else
            avgData = allData;
        end
    end

    if ~isequal(opts.Clip, [1 0])
        allData = timeClip(allData, opts.Clip, 2, opts.X);
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