function [A, xpts] = roiSignals(imStack, roiMask, varargin)
    % ROISIGNALS
    %
    % Description:
    %   Calculates dF/F for multiple ROIs
    %
    % Syntax:
    %   [A, xpts] = roiSignals(imStack, roiMask, varargin)
    %
    % Inputs:
    %   imStack         3D matrix - [X, Y, T]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [X, Y]
    %       Mask of designating ROI 
    % Optional key/value inputs (passed to roiSignal):
    %   FrameRate       numeric (default = 25)
    %       Samples/frames per second (Hz)
    %   BkgdWindow      vector [1 x 2]
    %       Start and stop frames for background estimate, returns dF/F
    %   Median          logical (default = false)
    %       Use median for background estimation instead of mean
    %
    % Outputs:
    %   signal      vector - [N, T]
    %       Average response over time for each ROI
    %   xpts        vector - [1, T]
    %       Time points associated with signal
    %
    % See also:
    %   ROISIGNAL
    % 
    % History:
    %   06Nov2020 - SSP
    %   02Dec2020 - SSP - Added bkgd estimation options
    %   10Nov2021 - SSP - Converted optional arguments to key/value
    % ---------------------------------------------------------------------

    roiMask = double(roiMask);

    roiList = unique(roiMask(:));
    roiList(roiList == 0) = [];
    numROIs = numel(roiList);

    A = [];

    for i = 1:numROIs
        try
            [signal, xpts] = roiSignal(imStack, roiMask == roiList(i), varargin);
        catch
            signal = zeros([1, size(imStack, 3)]);
            warning('ROISIGNALS: Error extracting signal for ROI %u', i);
        end
        A = cat(1, A, signal);
    end
