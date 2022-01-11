function [A, xpts] = roiDFF(imStack, roiMask, bkgdWindow, varargin)
    % ROISIGNALS
    %
    % Description:
    %   Calculates dF/F for multiple ROIs
    %
    % Syntax:
    %   [A, xpts] = roiSignals(imStack, roiMask, bkgdWindow, varargin)
    %
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [X, Y]
    %       Label mask designating ROI 
    %   bkgdWindow      vector [1 x 2]
    %       Start and stop frames for background estimate, returns dF/F
    %
    % Optional key/value inputs :
    %   FrameRate       numeric (default = 25)
    %       Samples/frames per second (Hz)
    %   Median          logical (default = false)
    %       Use median for background estimation instead of mean
    %
    % Outputs:
    %   A           vector - [N, T]
    %       Average response over time for each ROI
    %   xpts        vector - [1, T]
    %       Time points associated with signal
    %
    % Note:
    %   If bkgdWindow is empty, raw response is returned
    %
    % See also:
    %   ROISIGNALS, ROIRESPONSES, ROIRESPONSE
    % 
    % History:
    %   06Nov2020 - SSP
    %   02Dec2020 - SSP - Added bkgd estimation options
    %   10Nov2021 - SSP - Converted optional arguments to key/value
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'FrameRate', 25, @isnumeric);
    addParameter(ip, 'Median', false, @islogical);
    parse(ip, varargin{:});
    
    sampleRate = ip.Results.FrameRate;
    useMedian = ip.Results.Median;
    
    roiMask = double(roiMask);
    
    roiList = unique(roiMask(:));
    roiList(roiList == 0) = [];
    numROIs = numel(roiList);

    A = [];

    for i = 1:numROIs
        [a, b] = find(roiMask == roiList(i));
        % Time course for each pixel in the ROI
        signal = zeros(numel(a), size(imStack, 3));
        for j = 1:numel(a)
            signal(j, :) = squeeze(imStack(a(j), b(j), :));
        end
        % Average timecourse over all pixels in the ROI
        signal = mean(signal);

        % Calculate DFF, if necessary
        if ~isempty(bkgdWindow)
            if useMedian
                bkgd = median(signal(bkgdWindow(1):bkgdWindow(2)));
            else
                bkgd = mean(signal(bkgdWindow(1):bkgdWindow(2)));
            end
            signal = (signal - bkgd) / bkgd;
        end
        A = cat(1, A, signal);
    end
    
    
    % Get xpts while accounting for first blank frame thrown out
    xpts = 1/sampleRate : 1/sampleRate : (size(imStack, 3)+1)/sampleRate;
    xpts(1) = [];
