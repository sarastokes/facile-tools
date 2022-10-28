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
    % Get the matrix of cycle responses
    if isrow(response)
        cycles = zeros(numel(peakIdx), cycleLength);
        for i = 1:numel(peakIdx)
            cycles(i,:) = response(peakIdx(i):peakIdx(i)+cycleLength-1);
        end
        avgCycle = mean(cycles, 1);
    else
        cycles = zeros(size(response, 1), numel(peakIdx), cycleLength);
        for i = 1:numel(peakIdx)
            cycles(:,i,:) = response(:, peakIdx(i):peakIdx(i)+cycleLength-1);
        end
        avgCycle = squeeze(mean(cycles, 2));
    end

    % If requested, average 
    if nargout > 2
        stimCycle = stim(peakIdx(1):peakIdx(1)+cycleLength-1);
    end


