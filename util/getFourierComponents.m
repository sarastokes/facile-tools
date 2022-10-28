function [Fs, Ps] = getFourierComponents(avgCycle, whichComponents)

    numComponents = numel(whichComponents);
    Fs = zeros(numComponents,1);
    Ps = zeros(numComponents,1);
    
    ft = fft(avgCycle);

    for i = 1:numComponents
        Fs(i) = abs(ft(whichComponents(i)+1)) / length(avgCycle)*2;
        Ps(i) = rad2deg(angle(ft(whichComponents(i)+1)));
    end
    