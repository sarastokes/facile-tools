function autoScaleImageCLim(hImage, threshold)
%autoScaleImageCLim auto-update an image axes' CLim based on displayed portion
%
% Syntax:
%    autoScaleImageCLim(hImage, threshold)
%
% Description:
%    autoScaleImageCLim(hImage) automatically updates the specified image's axis
%    CLim property to the 10th & 90th percentiles of CData values for the
%    displayed portion of the image. This CLim is automatically updated whenever
%    the image is updated, zoomed, panned or modified in any way.
%
%    autoScaleImageCLim(hImage, threshold) recalculates CLim based on a user-
%    specified threshold (default: 10). For example, if threshold=5, then the 5%
%    and 95% CData values are used for CLim. This threshold can be specified as
%    either a number in the range [1-49] (indicating full percentage), or as a
%    corresponding numeric fraction in the range [0-0.49].
%
% Inputs:
%    hImage - handle to a Matlab image object (optional; default=current image)
%    threshold - threshold for setting CLim (optional; default=10)
%
% Examples:
%    autoScaleImageCLim()           % auto-scale the current axes' image
%    autoScaleImageCLim(hImage,5)   % auto-scale image using 5%-95% CData limits
%    autoScaleImageCLim(hImage,.07) % auto-scale image using 7%-93% CData limits
%
% Warning:
%    This code relies on undocumented and unsupported Matlab functionality.
%    It works on Matlab R2014b+, but use at your own risk!
%
% Technical explanation:
%    A technical explanation of the code in this utility can be found on
%    http://undocumentedmatlab.com/blog/auto-scale-image-colors
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Change log:
%    2018-02-21: First version posted on the <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
    % Process input args
    if nargin < 1  % hImage was not specified
        % Find the current (or first) image in the current figure
        hFig = gcf;
        hAxes = get(hFig,'CurrentAxes');  % not gca(): it creates a new axes if no CurrentAxes
        hImage = findall(hAxes, 'type','image');
        if isempty(hImage)
            % No image found in current axes - get the first image in the figure
            hImage = findall(hFig, 'type','image');
        end
        if isempty(hImage)
            error('YMA:autoScaleImageCLim:noImage','Image was not specified nor found');
        end
    else  % hImage was specified - check that it's indeed an image...
        try
            hImage.CData;  % this will croack if not a valid image
        catch
            % assume hImage is the containing axes
            try
                hImage = findall(hImage, 'type','image');
                if isempty(hImage), error('badImage'); end
            catch
                error('YMA:autoScaleImageCLim:badImage','Bad image handle specified');
            end
        end
    end
    if nargin < 2
        threshold = 0.10;  % default threshold=10%
    elseif ~isnumeric(threshold) || isempty(threshold) || ~isscalar(threshold)
        error('YMA:autoScaleImageCLim:badThresh','Bad threshold specified: not a scalar numeric value between 0-0.49 or 1-49');
    elseif threshold < 0 || threshold > 49
        error('YMA:autoScaleImageCLim:badThresh','Bad threshold specified: not a scalar numeric value between 1-49');
    elseif threshold > 0.49 && threshold < 1
        error('YMA:autoScaleImageCLim:badThresh','Bad threshold specified: not a scalar numeric value between 0-0.49');
    elseif threshold >= 1
        threshold = threshold / 100;  % convert to fraction 0-0.49
    end
    %  all the specified images
    for idx = 1 : numel(hImage)
        % First rescale the current image
        rescaleAxesClim(hImage(idx));
        % Instrument image: add a listener to rescale upon any image updates
        addlistener(hImage(idx), 'MarkedClean', @rescaleAxesClim);
    end
    % Rescale axes CLim based on displayed image portion's CData
    function rescaleAxesClim(hImage, varargin)
        % Check for callback reentrancy
        inCallback = getappdata(hImage, 'inCallback');
        if ~isempty(inCallback), return, end
        try
            setappdata(hImage, 'inCallback',1);  % prevent reentrancy
            % Get the displayed image portion's CData
            hAx = hImage.Parent;
            XLim = fix(hAx.XLim);
            YLim = fix(hAx.YLim);
            CData = hImage.CData;
            rows = min(max(min(YLim):max(YLim),1),size(CData,1)); % visible portion
            cols = min(max(min(XLim):max(XLim),1),size(CData,2)); % visible portion
            CData = CData(unique(rows),unique(cols));
            CData = CData(:);  % it's easier to work with a 1d array
            % Find the CLims from this displayed portion's CData
            CData = sort(CData(~isnan(CData)));  % or use the Stat Toolbox's prctile()
            thresholdVals = [threshold, 1-threshold];
            thresholdIdxs = fix(numel(CData) .* thresholdVals);
            CLim = CData(thresholdIdxs);
            % Update the axes
            hAx.CLim = CLim;
            drawnow; pause(0.001);  % finish all graphic updates before proceeding
        catch
        end
        setappdata(hImage, 'inCallback',[]);  % reenable this callback
    end
end
