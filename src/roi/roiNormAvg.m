function avgSignals = roiNormAvg(signals, bkgdWindow)

    if ismatrix(signals)
        for i = 1:numel(signals,1)
            signals(i,:) = rescale(signals(i,:));
            signals(i,:) = signals(i,:) - mean(signals(i,window2idx(bkgdWindow)));
        end
        avgSignals = signals;
        return
    end


    avgSignals = zeros(size(signals, 1), size(signals,2));
    for i = 1:size(signals,1)
        allSignals = squeeze(signals(i,:,:));
        for j = 1:size(signals,3)
            allSignals(:,j) = rescale(allSignals(:,j));
            allSignals(:,j) = allSignals(:,j) - mean(allSignals(window2idx(bkgdWindow),j));
        end
        avgSignals(i,:) = mean(allSignals, 2);
    end
    avgSignals = squeeze(avgSignals);