function [avgCycle, cycles, stimCycle] = cycleAverageFromSquareStim(response, stim, opts)
% CYCLEAVERAGEFROMSQUARESTIM


    arguments
        response            (:,:)   double
        stim
        opts.OmitCycles     (1,1)   {mustBeInteger, mustBeNonnegative} = 0
        opts.LED            (1,1)   {mustBeInRange(opts.LED, 1, 4)} = 4
    end

    if istable(stim)
        [ups, downs] = getSquareModulationTiming(stim, opts.LED, true);
    else
        [ups, downs] = getSquareModulationTiming(stim);
    end

    if opts.OmitCycles > 0
        ups(1:opts.OmitCycles,:) = [];
        downs(1:opts.OmitCycles,:) = [];
    end

    if istable(stim)
        switch opts.LED
            case 1
                stim = stim.R;
            case 2
                stim = stim.G;
            case 3
                stim = stim.B;
            case 4
                stim = stim.R + stim.G + stim.B;
        end
    end

    upFirst = ups(1,1) < downs(1,1);

    numCycles = min([size(ups, 1), size(downs, 1)]);
    cycleTimes = zeros(numCycles, 2);
    for i = 1:numCycles
        if upFirst
            cycleTimes(i,:) = [ups(i,1), downs(i,2)];
        else
            cycleTimes(i,:) = [downs(i,1), ups(i,2)];
        end
    end
    cycleLength = min(diff(cycleTimes, [], 2));

    if iscolumn(response)
        response = response';
    end

    cycles = zeros(size(response, 1), cycleLength, numCycles);
    for i = 1:numCycles
        cycles(:,:,i) = response(:, cycleTimes(i,1):cycleTimes(i,1)+cycleLength-1);
    end
    avgCycle = squeeze(mean(cycles, 3));

    % If requested, average
    if nargout > 2
        if upFirst
            stimCycle = stim(ups(1,1):downs(1,2));
        else
            stimCycle = stim(downs(1,1):ups(1,2));
        end
        stimCycle = stimCycle(1:cycleLength);
    end