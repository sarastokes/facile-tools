function [signals, xpts] = roiResponse(imStack, roi, bkgdWindow, varargin)
    % ROIRESPONSES
    %
    % Syntax:
    %   [signals, xpts] = roiResponses(imStack, rois, bkgdWindow, varargin)
    %
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roi             binary 2D matrix [X, Y]
    %       Label mask designating ROI 
    %   bkgdWindow      vector [1 x 2]
    %       Start and stop frames for background estimate (default=[])
    %
    % Optional key/value inputs :
    %   FrameRate       numeric (default = 25)
    %       Samples/frames per second (Hz)
    %   Method          char
    %       dff, zscore (default = 'dff')
    % Additional key/value inputs are passed to roiDFF and roiZScores
    %
    % Note:
    %   If bkgdWindow is empty, raw response is returned
    %
    % See also:
    %   ROIDFF, ROIZSCORES, ROIRESPONSES
    %
    % History:
    %   01Jan2022
    % ---------------------------------------------------------------------
    
    if nargin < 3 
        bkgdWindow = [];
    end
        
    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'Method', 'dff', @ischar);
    addParameter(ip, 'SampleRate', 25, @isnumeric);
    parse(ip, varargin{:});
    
    respType = ip.Results.Method;
    sampleRate = ip.Results.SampleRate;
    
    if strcmpi(respType, 'zscore')
        % Use DFF function to get raw fluorescence (no bkgdWindow)
        signals = roiDFF(imStack, roi, [], ip.Unmatched);
        % Pass fluorescence to the Z-score function
        signals = roiZScores(signals, bkgdWindow);
    else
        signals = roiDFF(imStack, roi, bkgdWindow, ip.Unmatched);
    end
    
    % Get xpts while accounting for first blank frame thrown out
    if nargout == 2 
        xpts = 1/sampleRate : 1/sampleRate : (size(imStack, 3)+1)/sampleRate;
        xpts(1) = [];
    end