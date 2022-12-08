classdef SpectralData < handle 

    properties
        experimentDate 
        source
        eyeName
        imagingSide
        imSize

        epochIDs 

        rois 
        roiUIDs
        avgImage
        ledTables
        frameTables
        frameRates
    end

    properties (SetAccess = private)
        stim 
        numROIs
        videoNames  
        transforms 
        baseDirectory
    end
    
    properties (SetAccess = private)
        workingDirectory
        ledStimNames
        stimulusFiles
    end

    properties (Constant)
        frameRate = 25.3;  % Hz
    end

    properties (Dependent)
        numEpochs
    end

    properties (Hidden, Dependent)
        videoCache 
        filePath
    end

    properties (Hidden, Transient, Access = protected)
        cachedVideos
    end

    methods
        function obj = SpectralData(expDate, source, epochIDs, expPath, varargin)
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            obj.source = source;
            obj.epochIDs = sort(epochIDs);
            obj.baseDirectory = expPath;
            if ~endsWith(obj.baseDirectory, filesep)
                obj.baseDirectory = [obj.baseDirectory, filesep];
            end
            
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Eye', '', @(x) ismember(lower(x), {'os', 'od'}));
            addParameter(ip, 'ImagingSide', 'none', @ischar);
            addParameter(ip, 'ImageSize', [242 360], @isnumeric);
            parse(ip, varargin{:});
            obj.eyeName = ip.Results.Eye;
            obj.imagingSide = ip.Results.ImagingSide;
            obj.imSize = ip.Results.ImageSize;

            % Extract video names
            obj.getVideoNames();

            % Initialize properties
            obj.transforms = containers.Map();
            obj.videoCache = containers.Map();
        end
    end

    % Dependent set/get methods
    methods 
        function value = get.numEpochs(obj)
            if isempty(obj.epochIDs)
                value = 0;
            else
                value = numel(obj.epochIDs);
            end
        end

        function videoCache = get.videoCache(obj)
            if isempty(obj.cachedVideos)
                obj.cachedVideos = containers.Map();
            end
            videoCache = obj.cachedVideos;
        end
        
        function set.videoCache(obj, x)
            obj.cachedVideos = x;
        end
    
        function value = get.filePath(obj)
            if isempty(obj.workingDirectory)
                value = obj.baseDirectory;
            else
                value = obj.workingDirectory;
            end
        end
    end

    methods
        function setWorkingDirectory(obj, filePath)
            % SETWORKINGDIRECTORY
            %
            % Description:
            %   Set a temporary filepath that replaces baseDirectory. Useful
            %   if you are analyzing data on multiple computers
            %
            % Syntax:
            %   setWorkingDirectory(obj, filePath)
            % -------------------------------------------------------------
            assert(isfolder(filePath), 'filePath is not valid!');
            obj.workingDirectory = filePath;
        end
    
        function clearVideoCache(obj)
            % CLEARVIDEOCACHE
            %
            % Description:
            %   Clear all cached videos
            % 
            % Syntax:
            %   clearVideoCache(obj)
            % -------------------------------------------------------------
            obj.videoCache = containers.Map();
        end
        
        function clearTransforms(obj)
            % CLEARTRANSFORMS
            % 
            % Description:
            %   Clear all transforms
            %
            % Syntax:
            %   obj.clearTransforms()
            % -------------------------------------------------------------
            obj.transforms = containers.Map();
        end
    end

    % Access methods
    methods
        function idx = epoch2idx(obj, epochID)
            idx = find(obj.epochIDs == epochID);
        end

        function epoch = idx2epoch(obj, idx)
            epoch = obj.epochIDs(idx);
        end
    end

    methods
        function imStack = getEpochStack(obj, epochID)
            % GETEPOCHSTACK
            % 
            % Description:
            %   Get video for a specific epoch
            % 
            % Syntax:
            %   imStack = getEpochStack(obj, epochID)
            %
            % Output:
            %   imStack     uint8 matrix [X Y T]
            % -------------------------------------------------------------
            
            % First check the video cache
            if isKey(obj.videoCache, num2str(epochID))
                imStack = obj.videoCache(num2str(epochID));
                return
            end
            
            % If not in the cache, load the video
            idx = obj.epoch2idx(epochID);
            if isempty(idx)
                error('No epochs matched %u', epochID);
            end
            
            % Get the video name
            if ~isempty(obj.workingDirectory)
                videoName = normPath(strrep(char(obj.videoNames(idx)),... 
                    obj.baseDirectory, obj.filePath));
            else
                videoName = normPath(char(obj.videoNames(idx)));
            end
            disp(videoName)
            tic
            if endsWith(videoName, '.tif')
                imStack = readTiffStack(videoName);
            elseif endsWith(videoName, '.avi')
                imStack = video2stack(videoName, 'Side', obj.imagingSide);
            end
            toc;

            % Remove the first blank frame
            imStack(:, :, 1) = [];
            
            % Apply a transform, if necessary
            if ~isempty(obj.transforms) && isKey(obj.transforms, num2str(epochID)) ...
                    && ~isempty(obj.transforms(num2str(epochID)))
                disp('Applying transform');
                try
                    tform = affine2d_to_3d(obj.transforms(num2str(epochID)));
                    sameAsInput = affineOutputView(size(imStack), tform,... 
                        'BoundsStyle','SameAsInput');
                    imStack = imwarp(imStack, tform,... 
                        'OutputView', sameAsInput);
                catch
                    [x, y, t] = size(imStack);
                    refObj = imref2d([x y]);
                    for i = 1:t
                        imStack(:,:,i) = imwarp(imStack(:,:,i), refObj,...
                            obj.transforms(num2str(epochID)),...
                            'OutputView', refObj);
                    end
                end
            end
            
            % Get the true frame count
            iStim = obj.epoch2stim(epochID);
            nFrames = iStim.frames();
            % Clip off the extra frames
            try
                imStack = imStack(:,:,1:nFrames);
            catch
                warning('Epoch %u size did not match nFrames (%u)', epochID, nFrames);
            end
            

            % Add it to the video cache
            obj.videoCache(num2str(epochID)) = imStack;
            
            % Status update: print video name without file path
            videoName = strsplit(videoName, filesep);
            fprintf('Loaded %s\n', videoName{end}); 
        end 
         
        function imStacks = getEpochStacks(obj, epochIDs)
            % GETEPOCHSTACKS
            %
            % Description:
            %   Get multiple epoch videos
            %
            % Syntax:
            %   imStacks = obj.getEpochStacks(epochIDs)
            %
            % Output:
            %   imStack     uint8 matrix [X Y T R]
            % -------------------------------------------------------------
            imStacks = [];
            for i = 1:numel(epochIDs)
                try
                    imStacks = cat(4, imStacks, obj.getEpochStack(epochIDs(i)));
                catch
                    warning('Epoch %u was the wrong size, skipping', epochIDs(i));
                end
            end
        end

        function imStack = getEpochStackAverage(obj, epochIDs)
            % GETEPOCHSTACKAVERAGE
            %
            % Description:
            %   Get the average video from specific epochs
            % 
            % Syntax:
            %   imStack = getEpochStackAverage(obj, epochIDs)
            % -------------------------------------------------------------
            if ~isnumeric(epochIDs)
                epochIDs = obj.stim2epochs(epochIDs);
            end
            imStack = [];
            for i = 1:numel(epochIDs)
                imStack = cat(4, obj.getEpochStack(epochIDs(i)));
            end
            imStack = squeeze(mean(imStack, 4));
        end
        
        function [signals, xpts] = getEpochResponses(obj, epochID, varargin)
            % GETEPOCHRESPONSES
            % 
            % Description:
            %   Get all ROI responses for specific epoch(s)
            %
            % Syntax:
            %   [signals, xpts] = getEpochResponses(obj, epochID, varargin)
            %   [signals, xpts] = obj.getEpochResponses(epochID, bkgd,
            %       varargin);
            %
            % Inputs:
            %   epochID         Epoch ID(s)
            % Optional input:
            %   bkgd            Range of background values (default = [])
            % Optional key/value inputs:
            %   Method          dff, zscore (default = 'dff')
            %                   Only applies if bkgd was supplied
            %   Stim            stimulus (default = [])
            %   Average         Average responses (default = false)
            %   Smooth          Sigma (default = [], no smoothing)
            %   HighPass        Cutoff frequency in Hz (default = [])
            %   BandPass        Frequency range in Hz (default = [])
            %
            % Note:
            %   If bkgd is empty or not specified, the raw fluorescence
            %   traces will be returned
            % -------------------------------------------------------------
            if isempty(obj.rois)
                error('EpochGroup/getEpochResponses: No rois found!');
            end
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Bkgd', [], @isnumeric);
            addParameter(ip, 'Average', false, @islogical);
            addParameter(ip, 'Smooth', [], @isnumeric);
            addParameter(ip, 'HighPass', [], @isnumeric);
            addParameter(ip, 'LowPass', [], @isnumeric);
            addParameter(ip, 'BandPass', [], @(x) numel(x)==2 & isnumeric(x));
            parse(ip, varargin{:});

            bkgdWindow = ip.Results.Bkgd;
            avgFlag = ip.Results.Average;
            smoothFac = ip.Results.Smooth;
            lowPassCutoff = ip.Results.LowPass;
            highPassCutoff = ip.Results.HighPass;
            bandPassCutoff = ip.Results.BandPass;
            
            if cellfind(ip.UsingDefaults, 'Bkgd')
                iStim = obj.epoch2stim(epochID(1));
                bkgdWindow = iStim.bkgd();
            end
            
            if numel(epochID) == 1
                imStack = obj.getEpochStack(epochID);
                [signals, xpts] = roiResponses(imStack, obj.rois, bkgdWindow,...
                    'FrameRate', obj.frameRate, ip.Unmatched);
            else % Multiple epochs
                iStim = obj.epoch2stim(epochID(1));
                signals = zeros(obj.numROIs, iStim.frames(), numel(epochID));
                for i = 1:numel(epochID)
                    imStack = obj.getEpochStack(epochID(i));
                    [A, xpts] = roiResponses(imStack, obj.rois, bkgdWindow,...
                        'FrameRate', obj.frameRate, ip.Unmatched);
                    try
                        signals(:, :, i) = A;
                    catch
                        % Epoch ended early or, for some reason, is long
                        offset = size(signals,2) - size(A,2);
                        if offset > 0
                            warning('Epoch %u is %u points too short! Filled with NaN',...
                                epochID(i), offset);
                            signals(:, :, i) = [A, NaN(size(A,1), offset)];
                        else
                            error('Epoch %u is %u points too long!',...
                                epochID(i), abs(offset));
                        end
                    end
                end
            end
            
            if ~isempty(smoothFac)
                if ndims(signals) == 3
                    signals = mysmooth32(signals, smoothFac);
                elseif ndims(signals) == 2 %#ok<*ISMAT> 
                    signals = mysmooth2(signals, smoothFac);
                end
            end

            if ~isempty(bandPassCutoff)
                signals = signalBandPassFilter(signals, bandPassCutoff, obj.frameRate);
            end

            if ~isempty(highPassCutoff)
                signals = signalHighPassFilter(signals, highPassCutoff, obj.frameRate);
                if isempty(bkgdWindow)
                    signals = signalMeanCorrect(signals);
                else
                    signals = signalBaselineCorrect(signals, bkgdWindow); 
                end
            end

            if ~isempty(lowPassCutoff)
                signals = signalLowPassFilter(signals, lowPassCutoff, obj.frameRate);
            end

            if avgFlag && ndims(signals) == 3
                signals = mean(signals, 3);
            end
        end

        function [signals, xLoc, yLoc] = getEpochRoiPixelResponses(obj, epochID, roiID, varargin)
            % GETEPOCHROIPIXELRESPONSES
            %
            % Description:
            %   Get a matrix of responses from each pixel in an ROI
            %
            % Syntax:
            %   [signals, xLoc, yLoc] = getEpochRoiPixelResponses(obj,
            %       epochID, roiID, bkgd, varargin)
            %   [signals, xLoc, yLoc] = getEpochRoiPixelResponses(obj,
            %       epochID, roiID, varargin)
            %
            % Inputs:
            %   epochID         epochID(s) or stimulus name
            %   roiID           ID of ROI to analyze
            % Optional input:
            %   bkgd            Range of background values (default = [])
            % Optional key/value inputs:
            %   Method          dff, zscore (default = 'dff')
            %                   Only applies if bkgd was supplied
            %   Stim            stimulus (default = [])
            %   Average         Average responses (default = false)
            %   Smooth          Sigma (default = [], no smoothing)
            %   HighPass        Cutoff frequency in Hz (default = [])
            %   BandPass        Frequency range in Hz (default = [])
            %
            % Note:
            %   If bkgd is empty or not specified, the raw fluorescence
            %   traces will be returned
            % -------------------------------------------------------------
            if ~isnumeric(epochID)
                iStim = ao.SpectralStimuli.init(epochID);
                epochID = obj.stim2epochs(epochID);
            else
                iStim = obj.epoch2stim(epochID(1));
            end

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Bkgd', [], @isnumeric);
            addParameter(ip, 'Average', false, @islogical);
            addParameter(ip, 'Smooth', [], @isnumeric);
            addParameter(ip, 'HighPass', [], @isnumeric);
            addParameter(ip, 'BandPass', [], @(x) numel(x)==2 & isnumeric(x));
            parse(ip, varargin{:});

            bkgdWindow = ip.Results.Bkgd;
            avgFlag = ip.Results.Average;
            smoothFac = ip.Results.Smooth;
            highPassCutoff = ip.Results.HighPass;
            bandPassCutoff = ip.Results.BandPass;

            if cellfind(ip.UsingDefaults, 'Bkgd')
                bkgdWindow = iStim.bkgd();
            end

            if numel(epochID) == 1
                imStack = obj.getEpochStack(epochID);
                [signals, xLoc, yLoc] = getRoiPixels(imStack, obj.rois, roiID);
            %elseif numel(epochID) > 1 && avgFlag
            %    imStack = obj.getEpochStackAverage(epochID);
            %    [signals, xLoc, yLoc] = getRoiPixels(imStack, obj.rois, roiID);
            else % Multiple epochs
                iStim = obj.epoch2stim(epochID(1));
                for i = 1:numel(epochID)
                    imStack = obj.getEpochStack(epochID(i));
                    [A, xLoc, yLoc] = getRoiPixels(imStack, obj.rois, roiID);
                    if i == 1
                        signals = zeros(size(A,1), iStim.frames(), numel(epochID));
                    end
                    try
                        signals(:, :, i) = A;
                    catch
                        % Epoch ended early or, for some reason, is long
                        offset = size(signals,2) - size(A,2);
                        if offset > 0
                            warning('Epoch %u is %u points too short! Filled with NaN',...
                                epochID(i), offset);
                            signals(:, :, i) = [A, NaN(size(A,1), offset)];
                        else
                            error('Epoch %u is %u points too long!',...
                                epochID(i), abs(offset));
                        end
                    end
                end

            end
            
            if ~isempty(smoothFac)
                if ndims(signals) == 3
                    signals = mysmooth32(signals, smoothFac);
                elseif ndims(signals) == 2 %#ok<*ISMAT> 
                    signals = mysmooth2(signals, smoothFac);
                end
            end

            if ~isempty(highPassCutoff)
                signals = signalHighPassFilter(signals, highPassCutoff, obj.frameRate);
                if isempty(bkgdWindow)
                    signals = signalMeanCorrect(signals);
                else
                    signals = signalBaselineCorrect(signals, bkgdWindow);
                end
            end

            if ~isempty(bandPassCutoff)
                signals = signalBandPassFilter(signals, bandPassCutoff, obj.frameRate);
                if isempty(bkgdWindow)
                    signals = signalMeanCorrect(signals);
                else
                    signals = signalBaselineCorrect(signals, bkgdWindow);
                end
            end

            if avgFlag && ndims(signals) == 3
                signals = mean(signals, 3);
            end
            
        end
        
        function [signals, xpts] = getStimulusResponses(obj, whichStim, varargin)
            % GETSTIMULUSRESPONSES
            % 
            % Description:
            %   Get all ROI responses for a specific stimulus
            %
            % Syntax:
            %   [signals, xpts] = getStimulusResponses(obj, stimID, varargin)
            %
            % Inputs:
            %   whichStim          integer, char, ao.Stimuli
            %       Stimulus number in the obj.stim table, stimulus name or
            %       ao.Stimuli object
            % Optional key/value inputs:
            %   Average             logical (default=false)
            %       Average responses if more than one
            % Additional key/value inputs are passed to getEpochResponses
            %
            % Note: 
            %   See obj.stim table for the stimID or use 
            % -------------------------------------------------------------

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Bkgd', [], @isnumeric);
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});

            avgFlag = ip.Results.Average;
            bkgdWindow = ip.Results.Bkgd;

            epochs = obj.stim2epochs(whichStim);
            iStim = obj.epoch2stim(epochs(1));

            % If background window not specified, get stimulus default
            if cellfind(ip.UsingDefaults, 'Bkgd')
                iStim = obj.epoch2stim(epochID(1));
                bkgdWindow = iStim.bkgd();
            end

            signals = zeros(obj.numROIs, iStim.frames(), numel(epochs));
            for i = 1:numel(epochs)
                [A, xpts] = obj.getEpochResponses(epochs(i), bkgdWindow, ip.Unmatched);
                try
                    signals(:, :, i) = A;
                catch
                    if size(A,2) > size(signals,2)
                        signals(:,:,i) = A(:,1:size(signals,2));
                    else
                        signals = signals(:, 1:size(A,2), :);
                        signals(:,:,i) = A;
                    end
                end
            end
            if avgFlag && numel(epochs) > 1
                signals = squeeze(mean(signals,3));
            end
            signals = squeeze(signals);
        end


        
        function avgStack = getStimulusAverage(obj, stimulus)
            % GETSTIMULUSAVERAGE
            % 
            % Description:
            %   Get the average of all videos associated with a stimulus
            %
            % Syntax:
            %   avgStack = getStimulusAverage(obj, stimulusID);
            %
            % Inputs:
            %   stimulus            stimulus name
            %       Which stimulus to return all videos for
            % 
            % Outputs:
            %   avgStack            [X, Y, T]
            %       Average video for all presentations of stimulus
            %
            % -------------------------------------------------------------
            IDs = obj.stim2epochs(stimulus);

            avgStack = [];
            for i = 1:numel(IDs)
                avgStack = cat(4, avgStack, obj.getEpochStack(IDs(i)));
            end
            avgStack = squeeze(mean(avgStack, 4));
            
            if isempty(obj.imSize)
                obj.imSize = size(avgStack);
            end
        end       

        
        function QI = getStimulusQI(obj, stimName, varargin)
            % GETSTIMULUSQI
            % 
            % Description:
            %   Computes ROI quality indices from multiple repeats of stim
            % Syntax:
            %   QI = obj.getStimulusQI(stimName, varargin)
            %
            % See also:
            %   QUALITYINDEX
            % -------------------------------------------------------------
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Smooth', 100, @isnumeric);
            addParameter(ip, 'HighPass', [], @isnumeric);
            addParameter(ip, 'StartFrame', 1, @isnumeric);
            parse(ip, varargin{:});
            
            smoothFac = ip.Results.Smooth;
            hpCutoff = ip.Results.HighPass;
            startFrame = ip.Results.StartFrame;

            IDs = obj.stim2epochs(stimName);
            if numel(IDs) == 1
                QI = NaN(obj.numROIs, 1);
                return
            end

            signals = obj.getEpochResponses(IDs);

            if ~isempty(hpCutoff)
                signals = signalHighPassFilter(signals(:,startFrame:end,:),... 
                    hpCutoff, 1/obj.frameRate);
            end
            if ~isempty(smoothFac)
                signals = mysmooth32(signals(:,startFrame:end,:),... 
                    ip.Results.Smooth);
            end
            QI = qualityIndex(signals);
        end

        function stim = getEpochTrace(obj, epochID, whichLED)
            % GETEPOCHTRACE
            % 
            % Description:
            %   Returns LED voltage at each frame for specified epoch 
            %
            % Syntax:
            %   stim = getEpochTrace(obj, epochID, whichLED)
            %
            % Inputs:
            %   epochID         Epoch ID or stimulus name (first epochID
            %                   matching the stim name will be used)
            %   whichLED        1 = red, 2 = green, 3 = blue, 4 = sum
            % -------------------------------------------------------------
            if nargin < 3
                whichLED = 4;
            end

            if ~isnumeric(epochID)
                epochs = obj.stim2epochs(epochID);
                epochID = epochs(1);
            end
            
            stim = [];
            for i = 1:numel(epochID)
                T = obj.frameTables(epochID(i));
                switch whichLED 
                    case 1
                        stim = cat(2, stim, T.R);
                    case 2
                        stim = cat(2, stim, T.G);
                    case 3
                        stim = cat(2, stim, T.B);
                    otherwise
                        stim = cat(2, stim, T.R + T.G + T.B);
                end
            end
        end
    end

    % Stimulus methods
    methods
        function stim = epoch2stim(obj, epochID)
            % EPOCH2STIM
            % -------------------------------------------------------------
            stim = obj.ledStimNames(obj.epoch2idx(epochID));
        end
        
        function epochIDs = stim2epochs(obj, stim)
            % STIM2EPOCHS
            % -------------------------------------------------------------
            if ~isa(stim, 'ao.SpectralStimuli')
                stim = ao.SpectralStimuli.init(stim);
            end
            idx = find(obj.ledStimNames == stim)';
            epochIDs = obj.epochIDs(idx);
        end

        function ID = getStimID(obj, stimName)
            % GETSTIMID
            %
            % Description:
            %   Get the ID number of a specific stimulus
            %
            % Syntax:
            %   ID = getStimID(obj, stimName)
            % -------------------------------------------------------------
            if ischar(stimName)
                ID = find(obj.stim.Stimulus == ao.Stimuli.init(stimName));
            else
                ID = find(obj.stim.Stimulus == stimName);
            end
        end
   
        function tf = isStimPresent(obj, stimName)
            % ISSTIMVALID
            %
            % Description:
            %   Returns whether stimulus is present in experiment
            %
            % Syntax:
            %   tf = obj.isStimPresent(stimName)
            % -------------------------------------------------------------
            if ~isa(stimName, {ao.Stimuli, ao.SpectralStimuli})
                try
                    stimName = ao.Stimuli.init(stimName);
                catch
                    stimName = ao.SpectralStimuli.init(stimName);
                end
            end
            tf = isempty(find(obj.stim.Stimulus == stimName)); %#ok<EFIND> 
        end
        
        function [ups, downs] = getModWindows(obj, ID, varargin)
            % GETMODWINDOWS
            %
            % Description:
            %   Returns frame/time windows for increments and decrements
            %
            % Syntax:
            %   [ups, downs] = obj.getModWindows(stimName, varargin)
            %
            % See also:
            %   GETSQUAREMODULATIONTIMING
            % -------------------------------------------------------------\
            if ~isnumeric(ID)
                ID = obj.stim2epochs(ID);
                ID = ID(1);
            end
            [ups, downs] = getSquareModulationTiming(obj.frameTables(ID), varargin{:});
        end

        
        function plotLEDs(obj, epochID, justRed)
            % PLOTLEDS
            %
            % Syntax:
            %   obj.plotLEDs(epochID, justRed)
            % 
            % -------------------------------------------------------------
            if nargin < 3
                justRed = false;
            end

            if isempty(obj.ledTables) || ~isKey(obj.ledTables, epochID)
                warning('LEDs not found for epoch %u', epochID);
                return
            end
            T = obj.ledTables(epochID);
            if justRed
                figure(); hold on;
                plot(T.Timing, T.R, 'LineWidth');
            else
                ledPlot([T.R, T.G, T.B], T.Timing / 1000);
            end
            ylim([0 5]);
        end
        
        function plotFrames(obj, epochID, justRed)
            % PLOTFRAMES
            %
            % Syntax:
            %   obj.plotLEDs(epochID, justRed)
            % ---------------------------------------------------------
            if nargin < 3
                justRed = false;
            end

            if isempty(obj.frameTables) || ~isKey(obj.frameTables, num2str(epochID))
                warning('Frames not found for epoch %u', epochID);
                return;
            end
            T = obj.frameTables(epochID);
            if justRed
                figure(); hold on;
                plot(T.Timing, T.R);
            else
                ledPlot([T.R, T.G, T.B], T.Timing / 1000);
            end
            ylim([0 5]);
        end

    end

    % Analysis methods
    methods 
        function makeStackSnapshots(obj, IDs)
            % MAKESTACKSNAPSHOTS
            %
            % Description:
            %   Mimics the Z-projections created by ImageJ and saves an
            %   AVG, MAX, SUM and STD projection to 'Analysis/Snapshots/'
            %
            % Syntax:
            %   obj.makeStackSnapshots(IDs);
            %
            % Optional Inputs:
            %   IDs         array
            %       Epoch IDs to create snapshots (default = obj.epochIDs)
            % -------------------------------------------------------------
            if nargin < 2
                IDs = obj.epochIDs;
            end
            
            fPath = normPath([obj.filePath, filesep, 'Analysis', filesep, 'Snapshots', filesep]);
            progressbar();
            for i = 1:numel(IDs) 
                baseName = ['_', obj.getShortName(IDs(i)), '.png'];
                imStack = obj.getEpochStack(IDs(i));
                
                % TODO: omit dropped frames
                
                imSum = sum(im2double(imStack), 3);
                imwrite(uint8(255 * imSum/max(imSum(:))),...
                    [fPath, 'SUM', baseName], 'png');
                imwrite(uint8(mean(imStack, 3)),...
                    [fPath, 'AVG', baseName], 'png');
                imwrite(uint8(max(imStack, [], 3)),... 
                    [fPath, 'MAX', baseName], 'png');
                imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))),... 
                    [fPath, 'STD', baseName], 'png');
                progressbar(i / numel(IDs));
            end
            progressbar(1);
        end
        
        function xy = getRoiCenters(obj, ID)
            % GETROICENTERS
            %
            % Description:
            %   Get the centroids of all rois (default) or specific roi(s)
            %
            % Syntax:
            %   xy = obj.getRoiCentroids(ID)
            %
            % Optional inputs:
            %   ID          numeric
            %       Specific roi ID(s), otherwise returns all rois
            % -------------------------------------------------------------
            if isempty(obj.rois)
                error('AO.CORE.DATSET: No rois found!');
            end

            S = regionprops("table", obj.rois, "Centroid");
            xy = S.Centroid;
            if nargin == 2
                xy = xy(ID,:);
            end
        end
    end
    
    % Initialization methods that may be run again with new values
    methods
        function setAvgImage(obj, im)
            % SETAVGIMAGE
            %
            % Description:
            %   Set a representative image of the region imaged
            %
            % Syntax:
            %   setAvgImage(obj, im)
            % -------------------------------------------------------------
            obj.avgImage = im;
        end

        function loadTransforms(obj, tforms, IDs)
            % LOADTRANSFORMS
            %
            % Description:
            %   Load epoch-specific transforms to apply on video import
            %
            % Syntax:
            %   loadTransforms(obj, tforms, IDs)
            %
            % Inputs:
            %   tforms      char OR [3 x 3 x N]
            %       SIFT output filename or matrix of N transformations
            % Optional inputs:
            %   IDs         array
            %       Epoch IDs corresponding to tforms (default=2:end)
            % -------------------------------------------------------------
            
            obj.clearTransforms();
            
            if nargin < 3 || isempty(IDs)
                IDs = obj.epochIDs(2:end);
            end
            
            if ischar(tforms)
                tforms = readRigidTransform(tforms);
            end
            
            for i = 1:numel(IDs)
                obj.transforms(num2str(IDs(i))) = ...
                    affine2d(squeeze(tforms(:, :, i)));
            end
        end

        function loadROIs(obj, rois)
            % LOADROIS
            %
            %   obj.loadROIs(rois)
            %
            % Input:
            %   rois        filepath to imageJ rois or labelmatrix
            % -------------------------------------------------------------

            % If no input, guess the roi file name
            if nargin < 2
                rois = normPath([obj.filePath, '\Analysis\',... 
                    obj.getLabel(), '_RoiSet.zip']);
            end

            if ischar(rois)
                rois = normPath(rois);
                if ~isfile(rois)
                    error('loadROIs: File not found: %s', rois);
                end
                if endsWith(rois, 'zip')
                    [~, obj.rois] = roiImportImageJ(rois, [obj.imSize(1), obj.imSize(2)]);
                elseif endsWith(rois, 'csv')
                    obj.rois = csvread(rois); %#ok<CSVRD> 
                end
                obj.roiFileName = rois;
            else
                obj.rois = rois;
            end

            obj.numROIs = numel(unique(obj.rois)) - 1;
            obj.rois = double(obj.rois);

            % If there were existing ROIs, make sure to append to roiUIDs 
            % rather than erasing existing table
            if ~isempty(obj.roiUIDs)
                newROIs = obj.numROIs - height(obj.roiUIDs);
                newTable = table(height(obj.roiUIDs) + rangeCol(1, newROIs),...
                    repmat("", [newROIs, 1]), 'VariableNames', {'ID', 'UID'});
                newTable = [obj.roiUIDs; newTable];
            else
                newTable = table(rangeCol(1, obj.numROIs),...
                    repmat("", [obj.numROIs, 1]), 'VariableNames', {'ID', 'UID'});
            end
            obj.roiUIDs = newTable;
        end
    end

    % Initialization methods run during creation
    methods (Access = protected)
        function getVideoNames(obj)
            % GETVIDEONAMES
            %
            % Description:
            %   Get video names and paths for each epoch ID
            % -------------------------------------------------------------
            obj.videoNames = repmat("", [obj.numEpochs, 1]);
            for i = 1:obj.numEpochs
                obj.videoNames(i) = normPath([obj.baseDirectory,... 
                    'Analysis', filesep, 'Videos', filesep, 'vis_',... 
                    int2fixedwidthstr(obj.epochIDs(i), 4), '.tif']);
            end
        end

        function T = populateStimulusTable(obj)
            % POPULATESTIMULUSTABLE
            %
            % Description:
            %   Create "stim" property table
            % -------------------------------------------------------------
            if isempty(obj.ledStimNames)
                T = [];
                return;
            end

            stimNames = arrayfun(@string, obj.ledStimNames);
            
            [G, groupNames] = findgroups(stimNames);
            numStimuli = numel(groupNames);
            N = splitapply(@numel, obj.ledStimNames, G);

            epochs = cell(numStimuli, 1);
            idx = cell(numStimuli, 1);

            for i = 1:numStimuli
                epochs{i} = obj.epochIDs(stimNames == groupNames(i));
                idx{i} = find(stimNames == groupNames(i));
            end
            
            stimuli = arrayfun(@(x) ao.SpectralStimuli.init(x), groupNames);

            T = table((1:numel(groupNames))', N, stimuli, epochs, idx, ...
                'VariableNames', {'ID', 'N', 'Stimulus', 'Epochs', 'Index'});
        end

        function loadFrameTraces(obj)
            % LOADFRAMETRACES
            %
            % Syntax:
            %   obj.loadFrameTraces()
            % ---------------------------------------------------------
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            obj.frameTables = containers.Map('KeyType', 'double', 'ValueType', 'any');
            obj.frameRates = NaN(size(obj.epochIDs));
            baseStr = [num2str(double(obj.source)), '_', ...
                char(obj.experimentDate), '_ref_'];
            progressbar();
            for i = 1:numel(obj.epochIDs)
                fName = [obj.filePath, filesep, 'Ref', filesep, baseStr,... 
                    int2fixedwidthstr(obj.epochIDs(i), 4), '.csv'];
                try 
                    [T, obj.frameRates(i)] = getLedFrameValues( ...
                        obj.baseDirectory, obj.epochIDs(i));
                catch
                    T = [];
                    warning('Could not load %s', fName);
                end
                obj.frameTables(obj.epochIDs(i)) = T;
                progressbar(i / numel(obj.epochIDs));
            end
            progressbar(1);
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
        end
                
        function loadLedTraces(obj)
            % LOADLEDTRACES
            %
            % Syntax:
            %   obj.loadLEDTraces()
            % ---------------------------------------------------------
            obj.ledTables = containers.Map('KeyType', 'double', 'ValueType', 'any');

            visFiles = ls([obj.baseDirectory, filesep, 'Vis']);
            visFiles = string(deblank(visFiles));
            visFiles = visFiles(contains(visFiles, '.json'));

            progressbar();
            for i = 1:numel(obj.epochIDs)
                visStr = ['vis_', int2fixedwidthstr(obj.epochIDs(i), 4)];
                idx = find(contains(visFiles, visStr));
                if isempty(idx)
                    warning('JSON file for %u could not be found!', obj.epochIDs(i));
                    continue
                end
                fileName = visFiles(idx);
                try
                    T = readJsonLED([obj.baseDirectory, filesep, 'Vis', filesep, char(fileName)]);
                    % Add a column for epoch-specific timing
                    T.Timing = obj.getEpochTiming(T);
                catch
                    T = [];
                    warning('Could not load %s', fileName);
                end
                obj.ledTables(obj.epochIDs(i)) = T;
                progressbar(i / numel(obj.epochIDs));
            end
            progressbar(1);
        end
    end

    methods (Static, Access = private)
        function x = getEpochTiming(T)
            x = T.TimeStamp;
            x = x - x(1);
        end

        function y = getShortName(epochID)
            % GETSHORTNAME
            %
            % Description:
            %   Naming convention used for saving snapshots and .tif files
            % -------------------------------------------------------------
            y = ['vis_', int2fixedwidthstr(epochID, 4)];
        end
        
    end

end