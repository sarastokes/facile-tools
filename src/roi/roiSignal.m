function [signal, xpts] = roiSignal(imStack, roiMask, varargin)
    % ROISIGNAL
    %
    % Description:
    %   Calculates dF/F for a single ROI
    %
    % Syntax:
    %   roiSignal(imStack, roiMask, varargin);
    % 
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [X, Y]
    %       Mask of designating ROI 
    % Optional key/value inputs:
    %   FrameRate       numeric (default = 25)
    %       Samples/frames per second (Hz)
    %   BkgdWindow      vector [1 x 2]
    %       Start and stop frames for background estimate, returns dF/F
    %   Median          logical (default = false)
    %       Use median for background estimation instead of mean
    %
    % Outputs:
    %   signal      vector - [1, T]
    %       Average response within ROI over time
    %   xpts        vector - [1, T]
    %       Time points associated with signal 
    %
    % See also:
    %   ROISIGNALPLOT, ROISIGNALS
    % 
    % History:
    %   22Aug2020 - SSP
    %   02Dec2020 - SSP - Added bkgd estimation options
    %   19Dec2020 - SSP - Removed first frame from analysis
    %   10Nov2021 - SSP - Converted optional arguments to key/value
    % ---------------------------------------------------------------------
        
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'FrameRate', 25, @isnumeric);
    addParameter(ip, 'BkgdWindow', [], @isnumeric);
    addParameter(ip, 'Median', false, @islogical);
    parse(ip, varargin{:});
    
    sampleRate = ip.Results.FrameRate;
    useMedian = ip.Results.Median;
    
    % Get xpts while accounting for first blank frame thrown out
    xpts = 1/sampleRate : 1/sampleRate : (size(imStack, 3)+1)/sampleRate;
    xpts(1) = [];

    [a, b] = find(roiMask == 1);
    signal = zeros(numel(a), size(imStack, 3));
    for i = 1:numel(a)
        signal(i, :) = squeeze(imStack(a(i), b(i), :));
    end
    signal = mean(signal);
    
    if ~isempty(bkgdWindow)
        if useMedian
            bkgd = median(signal(bkgdWindow(1):bkgdWindow(2)));
        else
            bkgd = mean(signal(bkgdWindow(1):bkgdWindow(2)));
        end
        signal = (signal - bkgd) / bkgd;  % dF/F
    end