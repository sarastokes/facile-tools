function [onsetMap, offsetMap] = pixelOnsetOffsetMap(imStack, onsetWindow, offsetWindow, bkgdWindow, varargin)
    % PIXELONSETOFFSETMAP
    %
    % Syntax:
    %   [onsetMap, offsetMap] = pixelOnsetOffsetMap(imStack, onsetWindow, 
    %       offsetWindow, bkgdWindow, varargin)
    %
    % Inputs:
    %   imStack         video data [x, y, t]
    %   onsetWindow     [a b]
    %       where a and b are the first and last frames of the stimulus
    %   
    % ---------------------------------------------------------------------
    ip = inputParser();
    addParameter(ip, 'Smooth', [], @isnumeric);
    addParameter(ip, 'LowPass', [], @isnumeric);
    parse(ip, varargin{:});
    
    imStack = double(imStack);
    
    if ~isempty(ip.Results.Smooth)
        for i = 1:size(imStack, 1)
            for j = 1:size(imStack, 2)
                imStack(i, j, :) = smooth(squeeze(imStack(i, j, :)), smoothFac);
            end
        end
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
    
    
    