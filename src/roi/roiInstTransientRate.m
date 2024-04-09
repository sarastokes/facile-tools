function output = roiInstTransientRate(signals, sigma, sampleRate)
% ROIINSTTRANSIENTRATE
    if ndims(signals) == 3
        output = [];
        for i = 1:size(signals, 3)
            iOutput = roiInstantaneousTransientRate(signals(:,:,i), sigma, sampleRate);
            output = cat(3, output, iOutput);
        end
        return
    end

    filterSigma = sigma * sampleRate;
    newFilt = normpdf(1:10*filterSigma, 10*filterSigma/2, filterSigma);

    output = [];
    for i = 1:size(signals, 1)
        tmp = sampleRate * conv(signals(i,:), newFilt, 'same');
        output = cat(1, output, tmp);
    end

