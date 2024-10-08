classdef SimpleDataset < handle

    properties (SetAccess = protected)
        % The video numbers in the dataset
        epochIDs                double      {mustBeInteger}
        % A name for the experiment
        exptName                char
        % The experiment data folder (the one containing "Ref", "Vis", etc)
        exptFolder              char

        % The label mask for the ROI segmentation
        rois                    double
        numROIs        (1,1)    double      {mustBeInteger} = 0
        % A table of numeric ROI IDs and corresponding UIDs
        roiUIDs                 table
        % The ROI file name (used for reloading ROIs)
        roiFileName             char

        % Transformations from post-registration, if necessary
        transforms
    end

    properties
        imSize          (1,2)   double      {mustBeInteger} = [0 0]
        frameRate       (1,1)   double                      = 25.3
        avgImage
        notes                   string
    end

    properties (Dependent)
        numCached               double {mustBeInteger}
    end

    properties (Hidden, Dependent)
        videoCache
    end

    properties (Hidden, Transient, Access = protected)
        cachedVideos
    end

    methods
        function obj = SimpleDataset(exptName, exptFolder, epochIDs)
            obj.setExptName(exptName);
            obj.setExptFolder(exptFolder);
            obj.epochIDs = epochIDs;

            % Initialize properties
            obj.transforms = containers.Map();
            obj.videoCache = containers.Map();
        end

        function setExptFolder(obj, folderName)
            if ~isfolder(folderName)
                error("setExptFolder:FolderNotFound",...
                    "The folder named %s does not exist", folderName);
            end
            obj.exptFolder = folderName;
        end
    end

    % Utility methods
    methods
        function idx = epoch2idx(obj, epochID)
            idx = find(obj.epochIDs == epochID);

            if isempty(idx)
                error('epoch2idx:InvalidEpochID',...
                    'The epoch ID %u was not found', epochID);
            end
        end

        function epoch = idx2epoch(obj, idx)
            epoch = obj.epochIDs(idx);
        end

        function uid = roi2uid(obj, roiID)
            % ROI2UID
            %
            % Description:
            %   Given a roi ID, returns the UID
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if roiID > height(obj.roiUIDs)
                error('Roi ID %u not in roiUIDs', roiID);
            end
            uid = obj.roiUIDs{roiID, 'UID'};
        end

        function roiID = uid2roi(obj, uid)
            % UID2ROI
            %
            % Description:
            %   Given a UID, return the corresponding ROI ID
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            roiID = find(obj.roiUIDs.UID == uid);
        end
    end

    % Transform methods
    methods
        function setExptName(obj, name)
            % SETEXPTNAME
            obj.exptName = name;
        end

        function setAvgImage(obj, input)
            % SETAVGIMAGE
            %
            % Description:
            %   Load a ROI average image
            %
            % Syntax:
            %   obj.loadAvgImage(input)
            %
            % Inputs:
            %   input           char/string or 2D numeric
            %       The file path to the image or the image itself
            % -------------------------------------------------------------
            if istext(input)
                if ~contains(input, filesep)
                    input = fullfile(obj.exptFolder, 'Analysis', input);
                end
                obj.validateFile(input);
                obj.avgImage = imread(input);
            elseif ismatrix(input)
                obj.avgImage = input;
            else
                error('setAvgImage:InvalidInput',...
                    'Input must be a file path to the image or 2D numeric data');
            end
        end
    end

    methods
        function addTransforms(obj, tforms, IDs)
            % ADDTRANSFORMS
            %
            % Description:
            %   Add new transforms (clears video cache)
            %
            % Syntax:
            %   addTransforms(obj, tforms, IDs)
            %
            % Inputs:
            %   tforms          char OR [3 x 3 x N]
            %       SIFT output filename or matrix of N transforms
            % Optional inputs:
            %   IDs             array
            %       Epoch IDs corresponding to tforms (default = all)
            % -------------------------------------------------------------

            if nargin < 3 || isempty(IDs)
                IDs = obj.epochIDs;
            end

            % Clear the video cache
            obj.clearVideoCache();

            if istext(tforms)
                if ~contains(tforms, filesep)
                    tforms = fullfile(obj.exptFolder, 'Analysis', tforms);
                end
                obj.validateFile(tforms);
                tforms = readRigidTransform(tforms);
            end

            for i = 1:numel(IDs)
                if isnumeric(tforms)
                    obj.transforms(num2str(IDs(i))) = ...
                        affine2d(squeeze(tforms(:, :, i)));
                else
                    obj.transforms(num2str(IDs(i))) = tforms(i);
                end
            end
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

    % ROI methods
    methods
        function loadROIs(obj, rois, imSize)
            % LOADROIS
            %
            % Syntax:
            %   obj.loadROIs(rois)
            %
            % Input:
            %   rois        filepath to imageJ rois or labelmatrix
            % -------------------------------------------------------------

            if nargin > 2
                obj.imSize = imSize;
            end

            if istext(rois)
                if ~contains(rois, filesep)
                    rois = fullfile(obj.exptFolder, 'Analysis', rois);
                end
                obj.validateFile(rois);
                if endsWith(rois, 'zip')
                    [~, obj.rois] = roiImportImageJ(rois,...
                        [obj.imSize(1), obj.imSize(2)]);
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

        function reloadRois(obj)
            % RELOADROIS
            %
            % Description:
            %   Reload ROIs from filepath last used with loadRois
            %
            % Syntax:
            %   obj.reloadRois()
            % -------------------------------------------------------------
            if isempty(obj.roiFileName)
                error('reloadRois:RoifileNameMissing',...
                    "Use loadRois first to store the file name");
            end
            obj.loadROIs(obj.roiFileName);
        end

        function setRoiUIDs(obj, roiUIDs)
            % SETROIUIDS
            %
            % Description:
            %   Assign a table to the roiUIDs property
            %
            % Syntax:
            %   obj.setRoiUIDs(roiUIDs)
            % -------------------------------------------------------------
            if isstring(roiUIDs)
                roiUIDs = roiUIDs(:);
                assert(numel(roiUIDs) == obj.numROIs, ...
                    'Number of UIDs must equal number of ROIs');
                T = table((1:obj.numROIs)', roiUIDs,...
                    'VariableNames', {'ID', 'UID'});
                obj.roiUIDs = T;
            elseif istable(roiUIDs)
                assert(height(roiUIDs) == obj.numROIs,...
                    'Number of UIDs must equal number of ROIs');
                assert(isequal(string(roiUIDs.Properties.VariableNames), ["ID", "UID"]),...
                    'roiUID table columns must be named ID and UID');
                obj.roiUIDs = roiUIDs;
            else
                error('setRoiUIDs:InvalidInput', 'Must be table or string column');
            end
            obj.roiUIDs = sortrows(obj.roiUIDs, 'ID');
        end
    end

    % Data analysis methods
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
            % Inputs:
            %   epochID     double
            %       The epoch ID for the returned video
            %
            % Output:
            %   imStack     uint8 matrix [X Y T]
            %       The epoch's video with first blank frame omitted
            % -------------------------------------------------------------

            % First check the video cache
            if isKey(obj.videoCache, num2str(epochID))
                imStack = obj.videoCache(num2str(epochID));
                return
            end

            % If not in the cache, load the video
            videoName = fullfile(obj.exptFolder, 'Analysis', 'Videos',...
                sprintf("vis_%s.tif", int2fixedwidthstr(epochID, 4)));

            tic;
            if endsWith(videoName, '.mat')
                S = load(videoName);
                imStack = S.imStack;
            elseif endsWith(videoName, '.tif')
                imStack = readTiffStack(videoName);
            elseif endsWith(videoName, '.avi')
                imStack = video2stack(videoName);
            end

            % Remove the first blank frame
            imStack(:, :, 1) = [];

            % Apply a transform, if necessary
            if ~isempty(obj.transforms) && isKey(obj.transforms, num2str(epochID)) ...
                    && ~isempty(obj.transforms(num2str(epochID)))
                disp('Applying transform');
                tform = affine2d_to_3d(obj.transforms(num2str(epochID)));
                sameAsInput = affineOutputView(size(imStack), tform,...
                    'BoundsStyle','SameAsInput');
                imStack = imwarp(imStack, tform, 'OutputView', sameAsInput);
            end

            % Add it to the video cache
            obj.videoCache(num2str(epochID)) = imStack;

            % Status update: print video name without file path
            videoName = strsplit(videoName, filesep);
            fprintf('Loaded %s - Time elapsed: %.2f\n', videoName{end}, toc);
        end

        function [signals, xpts] = getEpochResponses(obj, epochID, varargin)
            % GETEPOCHRESPONSES
            %
            % Description:
            %   Get all ROI responses for specific epoch(s). If the start
            %   and stop frames for a background window are provided, the
            %   change in fluorescence (df/F) is returned. Otherwise, the
            %   raw fluorescence is returned.
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
            %   Stim            stimulus (default = [])
            %   Average         Average responses (default = false)
            %   Smooth          Sigma (default = [], no smoothing)
            %   HighPass        Cutoff frequency in Hz (default = [])
            %   BandPass        Frequency range in Hz (default = [])
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
            addParameter(ip, 'Norm', false, @islogical);
            parse(ip, varargin{:});

            bkgdWindow = ip.Results.Bkgd;
            avgFlag = ip.Results.Average;
            smoothFac = ip.Results.Smooth;
            lowPassCutoff = ip.Results.LowPass;
            highPassCutoff = ip.Results.HighPass;
            bandPassCutoff = ip.Results.BandPass;
            normFlag = ip.Results.Norm;

            if numel(epochID) == 1
                imStack = obj.getEpochStack(epochID);
                [signals, xpts] = roiResponses(imStack, obj.rois, bkgdWindow,...
                    'FrameRate', obj.frameRate, ip.Unmatched);
            else % Multiple epochs
                signals = [];
                for i = 1:numel(epochID)
                    imStack = obj.getEpochStack(epochID(i));
                    [A, xpts] = roiResponses(imStack, obj.rois, bkgdWindow,...
                        'FrameRate', obj.frameRate, ip.Unmatched);
                    try
                        signals = cat(3, signals, A);
                    catch
                        % Epoch ended early or, for some reason, is long
                        offset = size(signals,2) - size(A,2);
                        if offset > 0
                            warning('Epoch %u is %u points too short! Filled with NaN',...
                                epochID(i), offset);
                            signals = cat(3, signals, [A, NaN(size(A,1), offset)]);
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
                    signals = signalBaselineCorrect(signals, bkgdWindow, "median");
                end
            end

            if ~isempty(lowPassCutoff)
                signals = signalLowPassFilter(signals, lowPassCutoff, obj.frameRate);
            end

            if normFlag
                signals = signalNormalize(signals, 2);
            end

            if avgFlag && ndims(signals) == 3
                signals = mean(signals, 3);
            end
        end

        function makeStackSnapshots(obj, IDs)
            % MAKESTACKSNAPSHOTS
            %
            % Description:
            %   Mimics the Z-projections created by ImageJ and saves an
            %   AVG, MAX, SUM and STD projection to 'Analysis/Snapshots/'
            %
            % Syntax:
            %   obj.makeStackSnapshots(fPath);
            %
            % Optional Inputs:
            %   IDs            double
            %       Which epoch IDs to make snapshots for (default = all)
            % -------------------------------------------------------------
            if nargin < 2
                IDs = obj.epochIDs;
            end

            fPath = fullfile(obj.exptFolder, 'Analysis', 'Snapshots');
            for i = 1:numel(IDs)
                baseName = ['_', 'vis_', int2fixedwidthstr(obj.epochIDs(i), 4), '.png'];
                imStack = obj.getEpochStack(IDs(i));

                imSum = sum(im2double(imStack), 3);
                imwrite(uint8(255 * imSum/max(imSum(:))),...
                    fullfile(fPath, ['SUM', baseName]), 'png');
                imwrite(uint8(mean(imStack, 3)),...
                    fullfile(fPath, ['AVG', baseName]), 'png');
                imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))),...
                    fullfile(fPath, ['STD', baseName]), 'png');
            end
        end
    end


    % Video cache methods
    methods
        function videoCache = get.videoCache(obj)
            if isempty(obj.cachedVideos)
                obj.cachedVideos = containers.Map();
            end
            videoCache = obj.cachedVideos;
        end

        function set.videoCache(obj, x)
            obj.cachedVideos = x;
        end

        function value = get.numCached(obj)
            try
                if isempty(obj.cachedVideos)
                    value = 0;
                else
                    value = numel(obj.cachedVideos.keys());
                end
            catch
                value = 0;
            end
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
    end

    methods (Static, Access = private)
        function validateFile(fName)
            if ~isfile(fName)
                error('setAvgImage:InvalidFilePath',...
                    'File path %s not found', input);
            end
        end
    end
end