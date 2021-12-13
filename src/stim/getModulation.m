function [stim, tAxis] = getModulation(temporalFrequency, stimTime, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'PreTime', [], @isnumeric);        % sec
    addParameter(ip, 'TailTime', [], @isnumeric);       % sec
    addParameter(ip, 'SampleRate', 1000, @isnumeric);   % Hz
    addParameter(ip, 'Square', false, @islogical);      % square or sine wave
    addParameter(ip, 'Contrast', 1, @isnumeric);
    parse(ip, varargin{:});

    sampleRate = ip.Results.SampleRate;
    squarewave = ip.Results.Square;
    cnst = ip.Results.Contrast;

    tailTime = ip.Results.TailTime;
    tailPts = tailTime * sampleRate;

    preTime = ip.Results.PreTime;
    prePts = preTime * sampleRate;
    
    stimPts = stimTime * sampleRate;
    t = (1:stimPts) / sampleRate;
            
    if squarewave
        stim = cnst * sign(sin(temporalFrequency * 2 * pi * t));
    else
        stim = cnst * sin(temporalFrequency * 2 * pi * t);
    end

    if ~isempty(preTime)
        stim = [zeros(1, prePts), stim];
    end

    if ~isempty(tailTime)
        stim = [stim, zeros(1, tailPts)];
    end

    numPts = (preTime + stimTime + tailTime) * sampleRate;
    tAxis = (1:numPts) / sampleRate;
end