function T = signalOnsetOffset(A, onsetWindow, offsetWindow, bkgdWindow)

    if nargin < 4 && onsetWindow(1) > 1
        bkgdWindow = [1, onsetWindow - 1];
    end
    numROIs = size(A, 1);
    bkgd = zeros(numROIs, 1);
    onsets = zeros(numROIs, 1);
    offsets = zeros(numROIs, 1);

    for i = 1:numROIs
        bkgd(i) = mean(A(i, bkgdWindow(1):bkgdWindow(2)));
        onsets(i) = mean(A(i, onsetWindow(1):onsetWindow(2)));
        offsets(i) = mean(A(i, offsetWindow(1):offsetWindow(2)));
    end

    T = table([1:numROIs]', onsets, offsets, bkgd,...
        'VariableNames', {'ID', 'Onset', 'Offset', 'Bkgd'});
    
    T.During = T.Onset - T.Bkgd;
    T.After = T.Offset - T.Bkgd;
