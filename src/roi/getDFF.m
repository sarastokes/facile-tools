function dff = getDFF(rawResponses, bkgdWindow, useMedian)
    % GETDFF
    %
    % Inputs:
    %   rawResponses        matrix [N x T]
    %       ROI responses in rows, raw fluorescence
    %   bkgdWindow          [1 x 2]
    %       Start and stop frames for calculating baseline response
    % Optional inputs:
    %   useMedian           logical
    %       Use median for dff baseline instead of mean (default = false)
    % ---------------------------------------------------------------------
    
    if nargin < 3
        useMedian = false;
    end
    
    dff = zeros(size(rawResponses));
    numROIs = size(rawResponses, 1);
    for i = 1:numROIs
        if useMedian
            bkgd = median(rawResponses(i, bkgdWindow(1):bkgdWindow(2)));
        else
            bkgd = mean(rawResponses(i, bkgdWindow(1):bkgdWindow(2)));
        end
        dff(i,:) = (rawResponses(i, :) - bkgd) / bkgd;
    end