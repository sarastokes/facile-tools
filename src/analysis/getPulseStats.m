function T = getPulseStats(dataset, stim, varargin)
    % GETPULSESTATS
    %
    % Description:
    %   Calculate metrics quantifying the responses at onset and offset
    %
    % Syntax:
    %   T = getPulseStats(dataset, stim)
    %
    % Note:
    %   Assumes increments and decrements are not directly adjacent
    % 
    % History:
    %   11May2022 - SSP
    % ---------------------------------------------------------------------

    stim = validateStim(stim);
    epochIDs = dataset.stim2epochs(stim);

    ip = inputParser();
    ip.CaseSensitive = true;
    ip.KeepUnmatched = true;
    addParameter(ip, 'Bkgd', [250 498], @isnumeric);
    addParameter(ip, 'Avg', true, @islogical);
    parse(ip, varargin{:});

    bkgdWindow = ip.Results.Bkgd;
    avgReps = ip.Results.Avg;

    % Get the data and smooth it
    signals = dataset.getStimulusResponses(stim, bkgdWindow, ip.Unmatched);
    % signals = mysmooth(signals, 100);
    if avgReps && ndims(signals) == 3
        signals = mean(signals, 3);
    end

    [ups, downs] = stim.getStimWindows(dataset);

    onset = zeros(dataset.numROIs, size(ups,1));
    offset = zeros(size(onset));
    onoff = zeros(size(onset));
    maxVals = zeros(size(onset));
    for i = 1:size(ups,1)
        upTime = diff(ups(i,:));
        offsetFrames = ups(i,2) + [1, upTime];
        onset(:, i) = minormax(signals(:, window2idx(ups(i,:))), 2) - mean(signals(:,ups(i,1)-6:ups(i,1)-1),2);
        offset(:, i) = minormax(signals(:, window2idx(offsetFrames)), 2) - signals(:, ups(i,2));
        maxVals(:, i) = max(abs(signals(:, ups(i,1):offsetFrames(end))), [], 2);
        onoff(:, i) = (onset(:, i) - offset(:, i))./ (onset(:,i)+offset(:,i)) .* maxVals(:, i);
    end

    ID = rangeCol(1, dataset.numROIs);
    T = table(ID, onset, offset, onoff, maxVals);
    % for i = 1:size(ups, 1)
        % upTime = diff(ups(i,:));
        % offsetFrames = ups(i,2) + [1, upTime];

        % lastValue = signals(:, ups(i,2));
        % lastValues = mean(signals(:, ups(i,2)-5:ups(i,2)), 2);

        % onMean = mean(signals(:, window2idx(ups(i,:))), 2);
        % offMean = mean(signals(:, window2idx(offsetFrames)),2);
        % offMeanAdj = offMean - lastValue;
        % offMeanDiff = offMean - onMean;

        % onMax = minormax(signals(:, window2idx(ups(i,:))), 2);
        % offMax = minormax(signals(:, window2idx(offsetFrames)), 2);
        % offMaxAdj = offMax - lastValue;
        % offMaxDiff = offMax - onMax;
    % end

    % ratioMean = (onMean - offMean) ./ (onMean + offMean);
    % ratioMeanAdj = (onMean - offMeanAdj) ./ (onMean + offMeanAdj);
    % ratioMax = (onMax - offMax) ./ (onMax + offMax);
    % ratioMaxAdj = (onMax - offMaxAdj) ./ (onMax + offMaxAdj);


    % T = table(ID, onMean, offMean, offMeanAdj, offMeanDiff, onMax, offMax, offMaxAdj, offMaxDiff, ratioMean, ratioMeanAdj, ratioMax, ratioMaxAdj);

