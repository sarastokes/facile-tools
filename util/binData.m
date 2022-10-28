function d = binData(data, binRate, sampleRate)
    binSize = sampleRate / binRate;
    numBins = floor(length(data) / binSize);

    d = zeros(1, numBins);
    for i = 1:numBins
        idx = round(binSize*(i-1)) + 1 : round(binSize*i);
        d(i) = mean(data(idx));
    end
    