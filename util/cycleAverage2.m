function [avgCycle, cycles, stimCycle] = cycleAverage2(response, stim, varargin)
    % CYCLEAVERAGE
    %
    % ---------------------------------------------------------------------
    [~, peakIdx] = findpeaks(stim);
    % Remove the first and last
    peakIdx = peakIdx(2:end-1);
    % Get the minimum distance between peaks
    cycleLength = min(diff(peakIdx));
    % Get the matrix of cycle responses
    cycles = zeros(numel(peakIdx), cycleLength);
    for i = 1:numel(peakIdx)
        cycles(i,:) = response(peakIdx(i):peakIdx(i)+cycleLength-1);
    end
    avgCycle = mean(cycles, 1);

    if nargout == 3
        stimCycle = stim(1:cycleLength-1);
    end


