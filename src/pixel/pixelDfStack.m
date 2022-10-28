function [fStack, secondStack] = pixelDfStack(imStack, bkgdWindow, varargin)
    % PIXELDFSTACK
    %
    % Description:
    %   Convert fluorescence video pixels to dF
    %
    % Syntax:
    %   fStack = pixelDfStack(imStack, bkgdWindow, varargin)
    %
    % Inputs:
    %   imStack         [x, y, t]
    %       Calcium imaging video
    %   bkgdWindow      1x2 
    %       Start and stop frames for calculating baseline fluorescence
    %
    % Optional key/value inputs:
    %   downsampFac         integer
    %       How much to downsample the video (default = no downsampling)
    %   smoothFac           integer
    %       How much to smooth the data in time (default = no smoothing)
    %   gaussFac            integer
    %       How much to spatially smooth the data with imgaussfilt
    %   normFlag            logical
    %       Whether to normalize and center the output for visualization
    %   secondStack         double
    %       Second video to process similarly (good for matching stim)
    %
    % See also:
    %   DOWNSAMPLEMEAN, MYSMOOTH2, IMGAUSSFILT
    %
    % History:
    %   05May2022 - SSP
    %   12Jun2022 - SSP - Added second stack option
    %   21Jun2022 - SSP - Added normalization option
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'DownsampFac', [], @isnumeric);
    addParameter(ip, 'SmoothFac', [], @isnumeric);
    addParameter(ip, 'GaussFac', [], @isnumeric);
    addParameter(ip, 'SecondStack', [], @isnumeric);
    addParameter(ip, 'Norm', false, @islogical);
    parse(ip, varargin{:});

    downsampFac = ip.Results.DownsampFac;
    smoothFac = ip.Results.SmoothFac;
    gaussFac = ip.Results.GaussFac;
    normFlag = ip.Results.Norm;
    secondStack = ip.Results.SecondStack;

    if ~isa(imStack, 'double')
        imStack = im2double(imStack);
    end
    if ~isempty(secondStack) && ~isa(secondStack, 'dobule')
        secondStack = im2double(secondStack);
    end

    bkgd = squeeze(mean(imStack(:,:,window2idx(bkgdWindow)), 3));

    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x*y t]);
    bkgd = reshape(bkgd, [x*y, 1]);

    fStack = imStack - bkgd;

    if ~isempty(smoothFac)
        fStack = mysmooth2(fStack, smoothFac);
    end

    if ~isempty(downsampFac)
        fStack = downsampleMean(fStack, downsampFac);
        t = size(fStack,2);
        if ~isempty(secondStack)
            [x2, y2, t2] = size(secondStack);
            iStack = downsampleMean(secondStack(:), downsampFac);
            secondStack = reshape(iStack, x2, y2, ceil(t2/downsampFac));
        end
    end

    fStack = reshape(fStack, [x, y, t]);

    if ~isempty(gaussFac)
        for i = 1:size(fStack,3)
            fStack(:, :, i) = imgaussfilt(fStack(:,:,i), gaussFac);
        end
    end

    if isempty(normFlag)
        fStack = fStack / max(abs(fStack(:)));
        fStack = fStack / 2;
        fStack = fStack + 0.5;
    end