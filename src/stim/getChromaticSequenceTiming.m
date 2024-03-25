function T = getChromaticSequenceTiming(dataset, epochID, varargin)

    arguments
        dataset     (1,1)       ao.core.Dataset
        epochID     (1,1)       {mustBeInteger}
    end

    arguments (Repeating)
        varargin
    end

    signals = dataset.getEpochResponses(epochID, [250 498], varargin{:});

    frameTable = dataset.frameTables(epochID);

    redUp = getSquareModulationTiming(frameTable, 1, true);
    greenUp = getSquareModulationTiming(frameTable, 2, true);
    blueUp = getSquareModulationTiming(frameTable, 3, true);

    redDown = redUp(2)+1:diff(redUp)-1;
    greenDown = greenUp(2)+1:diff(greenUp)-1;
    blueDown = blueUp(2)+1:diff(blueUp)-1;

    T = table((1:dataset.numROIs)', 'VariableNames', {'ID'});

    T.RedOn = mean(signals(:,window2idx(redUp)), 2);
    T.GreenOn = mean(signals(:,window2idx(greenUp)), 2);
    T.BlueOn = mean(signals(:,window2idx(blueUp)), 2);

    T.RedOff = mean(signals(:,window2idx(redDown)), 2);
    T.GreenOff = mean(signals(:,window2idx(greenDown)), 2);
    T.BlueOff = mean(signals(:,window2idx(blueDown)), 2);






