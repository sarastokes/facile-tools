function [avgCycle, cycles, stimCycle] = cycleAverageFromStim(response, stim)
% CYCLEAVERAGEFROMSTIM
%
% Syntax:
%   [avgCycle, cycles, stimCycle] = cycleAverageFromStim(signal, stim)
%
% History:
%   27Oct2022 - SSP
% ---------------------------------------------------------------------

    [~, peakIdx] = findpeaks(stim);
    % Remove the first and last
    peakIdx = peakIdx(2:end-1);
    % Get the minimum distance between peaks
    cycleLength = min(diff(peakIdx));

    if iscolumn(response)
        response = response';
    end

    cycles = zeros(size(response, 1), cycleLength, numel(peakIdx));
    for i = 1:numel(peakIdx)
        cycles(:,:,i) = response(:, peakIdx(i):peakIdx(i)+cycleLength-1);
    end
    avgCycle = squeeze(mean(cycles, 3));

    % If requested, average
    if nargout > 2
        stimCycle = stim(peakIdx(1):peakIdx(1)+cycleLength-1);
    end


