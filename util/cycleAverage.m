function [y, x] = cycleData(data, temporalFrequency, varargin)
    % CYCLEDATA
    %
    % 

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'PreFrames', 0, @isnumeric);
    addParameter(ip, 'TailFrames', 0, @isnumeric);
    addParameter(ip, 'SampleRate', 25, @isnumeric);
    addParameter(ip, 'CyclesPerAverage', 1, @isnumeric);
    addParameter(ip, 'SkipCycles', 1, @isnumeric);
    addParameter(ip, 'Average', true, @islogical);
    parse(ip, varargin{:});

    cyclesPerAverage = ip.Results.cyclesPerAverage;
    skipCycles = ip.Results.SkipCycles;
    preFrames = ip.Results.PreFrames;
    tailFrames = ip.Results.TailFrames;
    sampleRate = ip.Results.SampleRate;
    sampleTime = 1 / sampleRate;  % Hz -> seconds
    avgFlag = ip.Results.Average;

    stimFrames = size(data, 2) - preFrames - tailFrames;
    if tailFrames > 0
        data(end-tailFrames+1:end) = [];
    end
    if preFrames > 0
        data(1:preFrames) = [];
    end

    stimTime = stimFrames * sampleTime;  % seconds

    numCycles = floor(cyclesPerAverage * temporalFrequency * stimTime);
    period = cyclesPerAverage * (1 ./ temporalFrequency) * sampleRate;

    for i = (skipCycles + 1) : numCycles
        
    end