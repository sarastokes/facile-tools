function [y, x] = cycleData(data, temporalFrequency, varargin)
    % CYCLEDATA
    %
    % Description:
    %   Split data into cycles (of a temporally modulated stimulus)
    %
    % Syntax:
    %   [y, x] = cycleData(data, temporalFrequency, varargin)
    %
    % History:
    %   08Feb2017 - SSP
    %   20Nov2017 - SSP - small updates   
    %   19Oct2020 - SSP - Cleaned up for 2p research
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'PreFrames', 0, @isnumeric);
    addParameter(ip, 'TailFrames', 0, @isnumeric);
    addParameter(ip, 'SampleRate', 25, @isnumeric);
    addParameter(ip, 'CyclesPerAverage', 1, @isnumeric);
    addParameter(ip, 'SkipCycles', 0, @isnumeric);
    addParameter(ip, 'Average', true, @islogical);
    parse(ip, varargin{:});

    cyclesPerAverage = ip.Results.CyclesPerAverage;
    skipCycles = ip.Results.SkipCycles;
    preFrames = ip.Results.PreFrames;
    tailFrames = ip.Results.TailFrames;
    sampleRate = ip.Results.SampleRate;
    sampleTime = 1 / sampleRate;  % Hz -> seconds
    avgFlag = ip.Results.Average;

    if size(data, 2) == 1 
        data = data';
    end

    stimFrames = size(data, 2) - preFrames - tailFrames;
    if tailFrames > 0
        data(end-tailFrames+1:end) = [];
    end
    if preFrames > 0
        data(1:preFrames) = [];
    end
    
    period = cyclesPerAverage * (1 ./ temporalFrequency) * sampleRate;
    numCycles = floor(stimFrames / period);
    disp(numCycles)
    disp(period)

    y = [];
    for i = (skipCycles + 1) : numCycles
        y = [y; data((i - 1)*period+1 : i*period)];
    end

    x = (1:length(y)) ./ sampleRate;
    if avgFlag
        y = mean(y, 1);
    end