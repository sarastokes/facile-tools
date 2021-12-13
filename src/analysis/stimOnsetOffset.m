function T = stimOnsetOffset(A, onsetWindow, offsetWindow, bkgdWindow)
    % STIMONSETOFFSET
    %
    % Description:
    %   Get average response to stimulus onset (during) and offset (after)
    %
    % Syntax:
    %   T = stimOnsetOffset(A, onsetWindow, offsetWindow, bkgdWindow)
    %
    % Inputs:
    %   A       N x T matrix
    %   onsetWindow     Data points for stimulus start and end
    %   offsetWindow    Data points for analyzing stimulus offset response
	%   bkgdWindow      Data points for background estimate (default, 1:onset)
    %
    % Output:
    %   T       Table with ROI ID, onset, offset and bkgd responses
    %
    % History:
    %   07Nov2020 - SSP
    % ---------------------------------------------------------------------

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
