function avgSignals = roiNormAvg(signals, bkgdWindow)
% ROINORMAVG
%
% Description:
%   Normalize (0-1) followed by translation to baseline correct, then
%   takes the average (if multiple repeats were provided)
%
% Syntax:
%   avgSignals = roiNormAvg(signals, bkgdWindow)
%
% See also:
%   rescale
% --------------------------------------------------------------------------
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