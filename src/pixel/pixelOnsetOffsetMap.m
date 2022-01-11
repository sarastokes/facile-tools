function [onsetMap, offsetMap] = pixelOnsetOffsetMap(imStack, onsetWindow, offsetWindow, bkgdWindow, varargin)
    % PIXELONSETOFFSETMAP
    %
    % Syntax:
    %   [onsetMap, offsetMap] = pixelOnsetOffsetMap(imStack, onsetWindow, 
    %       offsetWindow, bkgdWindow, varargin)
    %
    % History:
    %   02Jan2021 - Added averaging for multiple trials
    % ---------------------------------------------------------------------
    ip = inputParser();
    addParameter(ip, 'Smooth', [], @isnumeric);
    addParameter(ip, 'LowPass', [], @isnumeric);
    parse(ip, varargin{:});
    
    imStack = double(imStack);
    
    if ndims(imStack) == 4
        imStack = mean(imStack,4);
    end
    
    if ~isempty(ip.Results.Smooth)
        imStack = mysmooth32(imStack, smoothFac);
        bkgdWindow(1) = bkgdWindow(1) + smoothFac;
    end
    
    if ~isempty(ip.Results.LowPass)
        for i = 1:size(imStack, 1)
            for j = 1:size(imStack, 2)
                imStack(i, j, :) = lowPassFilter(squeeze(imStack(i, j, :)),...
                    ip.Results.LowPass, 0.04);  % Assumes 25 Hz sample rate
            end
        end
    end

    bkgdStack = squeeze(mean(imStack(:, :, bkgdWindow(1):bkgdWindow(2)), 3));
    onsetStack = squeeze(mean(imStack(:, :, onsetWindow(1):onsetWindow(2)), 3));
    offsetStack = squeeze(mean(imStack(:, :, offsetWindow(1):offsetWindow(2)), 3));
    
    onsetMap = onsetStack - bkgdStack;
    offsetMap = offsetStack - bkgdStack;
    
    
    