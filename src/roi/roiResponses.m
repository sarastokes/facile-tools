function [signals, xpts] = roiResponses(imStack, roiMask, bkgdWindow, varargin)
    % ROIRESPONSES
    %
    % Syntax:
    %   [signals, xpts] = roiResponses(imStack, rois, bkgdWindow, varargin)
    %
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [X, Y]
    %       Mask designating ROIs 
    %   bkgdWindow      vector [1 x 2]
    %       Start and stop frames for background estimate (default=[])
    %
    % Optional key/value inputs :
    %   SampleRate       numeric (default = 25)
    %       Samples/frames per second (Hz)
    %   Method          char
    %       dff, zscore (default = 'dff')
    % Additional key/value inputs are passed to roiDFF and roiZScores
    %
    % Note:
    %   If bkgdWindow is empty, raw response is returned
    %
    % See also:
    %   ROIDFF, ROIZSCORES
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
    addParameter(ip, 'SampleRate', 25, @isnumeric);
    parse(ip, varargin{:});
    sampleRate = ip.Results.SampleRate;
    
    % Get the number of ROIs (discounting background of 0s)
    roiMask = double(roiMask);
    numROIs = numel(unique(roiMask));
    if nnz(roiMask) > 0
        numROIs = numROIs - 1;
    end
    
    signals = zeros(numROIs, size(imStack,3));
    for i = 1:numROIs
        signals(i, :) = roiResponse(imStack, roiMask == i, bkgdWindow, varargin{:});
    end
        
    if nargout == 2
        xpts = 1/sampleRate : 1/sampleRate : (size(imStack, 3)+1)/sampleRate;
        xpts(1) = [];
    end