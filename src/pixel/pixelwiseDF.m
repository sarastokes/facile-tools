function [dfPop, dfStack, dfTrace] = pixelwiseDF(expt, epochID, stimWindow, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'leftVal', 5, @isnumeric);
    addParameter(ip, 'padVal', 15, @isnumeric);
    addParameter(ip, 'bkgdWindow', [150, 498]);
    addParameter(ip, 'useTrapz', false, @islogical);
    addParameter(ip, 'frameRate', 25.3, @isnumeric);
    addParameter(ip, 'Smooth', [], @isnumeric);
    parse(ip, varargin{:});

    padVal = ip.Results.padVal;
    leftVal = ip.Results.leftVal;
    useTrapz = ip.Results.useTrapz;
    bkgdWindow = ip.Results.bkgdWindow;
    frameTime = 1/ip.Results.frameRate;
    smoothFac = ip.Results.Smooth;

    imStack = expt.getEpochStack(epochID);
    if ~isa(imStack, 'double')
        imStack = im2double(imStack);
    end
    if ~isempty(smoothFac)
        imStack = mysmooth32(imStack, smoothFac);
    end

    % Remove regions where motion artifact may be present
    cropStack = imStack(padVal+1:end-padVal, leftVal+1:end-padVal, :);

    % Subtract the background fluorescence
    bkgd = squeeze(mean(cropStack(:,:,bkgdWindow(1):bkgdWindow(2)), 3));
    normStack = cropStack - bkgd;

    if useTrapz
        dfStack = zeros(size(normStack));
        for i = 1:size(normStack, 1)
            for j = 1:size(normStack, 2)
                dfStack(i,j,:) = frameTime * trapz(squeeze(normStack(i,j,:)));
            end
        end
    else
        resp = squeeze(mean(normStack(:,:,stimWindow(1):stimWindow(2)), 3));
        dfStack = resp - bkgd;
    end

    % Average over time
    dfPop = mean(dfStack(:));

    % Average over space
    dfTrace = squeeze(mean(cropStack, [1 2]));