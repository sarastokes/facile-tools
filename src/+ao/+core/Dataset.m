classdef Dataset < handle
% DATASET
%
% Description:
%   Contains a single experiment grouped for analysis: 1 day, 1 animal, 
%   1 eye, 1 imaging location) 
%
% Notes:
%   Dimensions are specified as:
%       Spatial: X, Y
%       Time: T
%       Repeats: R
%
% Properties:
%   experimentDir
%       This is where the code attempts to access the underlying data, it's 
%       baseDirectory unless workingDirectory exists via setWorkingDirectory
%
% Methods:
%   getEpochResponses
%   getEpochStack
%   getEpochStacks
%   getEpochStackAverage
%   getStimulusAverage
%   getStimulusResponses
%   getStimulusQI
%
%   epoch2idx
%   epoch2stim
%   getStimID
%   idx2epoch
%   stim2epochs
%   isStimPresent
%
%   getExperimentName
%   getLabel
%   setWorkingDirectory
%   addNote
%
%   clearVideoCache
%
%   loadAvgImage
%
%   addTransforms
%   clearTransforms
%   loadTransforms
%   getEpochRois
%
%   loadCalibration
%   getCalibration
%   clearCalibrations
%
%   addRoiUID
%   loadROIs
%   reloadRois
%   setRoiMeans
%   setRoiUIDs
%   
%   getRoiIntensities
%   getRoiCenters
%   makeStackSnapshots
%
%   checkRegistrationReports
%   getRegisteredVideoNames
% -------------------------------------------------------------------------

    properties 
        % User-specified (required, no defaults)
        experimentDate          % 'YYYYMMDD'
        source                  % ao.NHP
        baseDirectory           % File path to experiment folder
        epochIDs                % Video IDs to include
        imSize                  % [X Y T]
        rois                    % labelmask
        
        % User-specified (optional, or has reliable default values)
        eyeName                 % OD vs OS
        frameRate               % Hz
        pinhole                 % Microns
        defocus                 % D
        fieldOfView             % Degrees
        imagingSide             % left, right (of foveal ring)
        
        % Pulled from metadata
        pmtGains                % [reflectance, visible]
        droppedFrames           % Frames where registration software failed
        stimulusNames           % Stimulus names (from spec file)
        stimulusFiles           % Full path to stimulus specification file
        registeredVideos        % Visible channel processed video names
        roiFileName             % ROI file name, if used
        tformFileName           % Transform file name, if used
        
        % Calculated properties
        stim
        numROIs
        stimuliUsed
        transforms
        analysisRegion
        
        % Free properties
        calibrations            % containers.Map
        
        % Quick hack for LED compatibility
        ledVideoNames
        
        % Development
        roiUIDs
        avgImage
        warningIDs    double
        omittedEpochs 
    end

    % Rarely used/accessed properties, properties under development
    properties (Hidden)
        analyses                % containers.Map
        notes                   % cell
        roiMeans
        transformRois = false
        originalVideos          % Visible channel raw video names
        registrationReports     % Registration report file names
        registrationDate        % Date of video registration
        registrationID          % Registration number
        stimWavelength          % nm
        reflectVideos = false;
        reflectRois = false;
        extraHeader
    end

    properties (SetAccess = private)
        workingDirectory
    end

    properties (Dependent)
        numCached
    end
    
    properties (Hidden, Dependent)
        videoCache
        baseImageSize
        experimentDir
    end
    
    properties (Hidden, Transient, Access = protected)
        cachedVideos
    end

    methods
        function obj = Dataset(expDate, source, epochIDs, stimWL, baseDir, varargin)
            
            % Required parameters
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            if ~isa(source, 'ao.NHP')
                obj.source = ao.NHP.init(source);
            else
                obj.source = source;
            end
            obj.epochIDs = sort(epochIDs);
            obj.stimWavelength = stimWL;

            obj.baseDirectory = convertCharsToStrings(baseDir);
            if ~strcmp(obj.baseDirectory(end), filesep)
                obj.baseDirectory = [obj.baseDirectory, filesep];
            end

            % Set optional properties specified with key-value inputs
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Eye', '', @(x) ismember(lower(x), {'os', 'od'}));
            addParameter(ip, 'ImagingSide', 'none', @ischar);
            addParameter(ip, 'FieldOfView', [3.69, 2.77], @isnumeric);
            addParameter(ip, 'Pinhole', 20, @isnumeric);
            addParameter(ip, 'RegistrationDate', [], @ischar);
            addParameter(ip, 'RegistrationID', 1, @isnumeric);
            addParameter(ip, 'Defocus', 0.3, @isnumeric);
            addParameter(ip, 'FrameRate', 25, @isnumeric);
            addParameter(ip, 'LEDVideoNames', []);
            addParameter(ip, 'ExtraHeader', '', @ischar);
            parse(ip, varargin{:});
            
            obj.eyeName = ip.Results.Eye;
            obj.imagingSide = ip.Results.ImagingSide;
            obj.fieldOfView = ip.Results.FieldOfView;
            obj.defocus = ip.Results.Defocus;
            obj.pinhole = ip.Results.Pinhole;
            obj.frameRate = ip.Results.FrameRate;
            obj.ledVideoNames = ip.Results.LEDVideoNames;
            obj.extraHeader = ip.Results.ExtraHeader;

            if ~isempty(ip.Results.RegistrationDate)
                obj.registrationDate = datetime(ip.Results.RegistrationDate,... 
                    'Format', 'yyyyMMdd');
            end
            obj.registrationID = ip.Results.RegistrationID;
            
            % Set additional properties
            obj.getRegisteredVideoNames(obj.registrationDate, obj.registrationID);
            obj.extractEpochAttributes();
            if ~isempty(obj.registrationDate)
                obj.checkRegistrationReports();
            end
            
            % Initialize properties
            obj.transforms = containers.Map();
            obj.videoCache = containers.Map();
            obj.calibrations = containers.Map();
            obj.analyses = containers.Map();
            obj.notes = cell(0,1);
        end
    end

    % Dependent set/get methods
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

        function experimentDir = get.experimentDir(obj)
            if ~isempty(obj.workingDirectory)
                experimentDir = obj.workingDirectory;
            else
                experimentDir = obj.baseDirectory;
            end
        end

        function value = get.baseImageSize(obj)
            if isempty(obj.analysisRegion)
                value = obj.imSize(1:2);
            else
                value = [numel(window2idx(obj.analysisRegion(1,:))),...
                    numel(window2idx(obj.analysisRegion(2,:)))];
            end
        end
    end

    methods
        function save(obj, savePath)
            saveName = [char(obj.source), '_',...
                obj.eyeName, upper(obj.imagingSide(1)), '_',...
                char(obj.experimentDate)];
            x = cd;
            S = struct(saveName, obj);
            cd(savePath);
            save([saveName, '.mat'], '-struct', 'S');
            cd(x);
        end

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
            arguments
                obj
                filePath        char
            end
            
            assert(isfolder(filePath), 'filePath is not valid!');
            if filePath(end) ~= filesep
                filePath = [filePath, filesep];
            end
            obj.workingDirectory = filePath;
        end

        function setExtraHeader(obj, header)
            obj.extraHeader = header;
        end

        function setRoiMeans(obj, epochID, bkgdWindow)
            % SETROIMEANS
            %
            % Syntax:
            %   obj.setRoiMeans(epochID, bkgdWindow)
            % -------------------------------------------------------------
            signals = obj.getEpochResponses(epochID, []);
            if ~isempty(bkgdWindow)
                signals = signals(:, bkgdWindow);
            end
            obj.roiMeans = mean(signals, 2);
        end
        
        function addNote(obj, txt)
            % ADDNOTE
            % 
            % Syntax:
            %   obj.addNote(txt)
            % -------------------------------------------------------------
            obj.notes = cat(1, obj.notes, txt);
        end
        
        function x = getExperimentName(obj)
            % GETEXPERIMENTNAME
            %
            % Description:
            %   Return readable experiment identifier
            % -------------------------------------------------------------
            x = [num2str(double(obj.source)),... 
                '_', obj.eyeName, upper(obj.imagingSide(1)),...
                '_', char(obj.experimentDate)];
        end

        function x = getLabel(obj, includeLocation)
            % GETLABEL
            %
            % Syntax:
            %   x = obj.getLabel(includeLocation)
            % -------------------------------------------------------------

            if nargin < 2
                includeLocation = true;
            end

            % Check to see if location metadata is present
            if includeLocation 
                if isempty(obj.imagingSide)
                    error('AO.CORE.DATASET:getLabel - missing imaging side');
                end
            end
            
            if includeLocation               
                x = [num2str(double(obj.source)), '_',... 
                    obj.eyeName, upper(obj.imagingSide(1)), '_' ...
                    char(obj.experimentDate)];
            else
                x = [num2str(double(obj.source)), '_', obj.eyeName, ...
                    char(obj.experimentDate)];
            end
        end
    end
        
    methods      
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

        function clearCalibrations(obj)
            % CLEARCALIBRATIONS
            %
            % Description:
            %   Clear all calibrations
            %
            % Syntax:
            %   obj.clearCalibrations()
            % -------------------------------------------------------------
            obj.calibrations = containers.Map();
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
        
        function idx = epoch2idx(obj, epochID)
            idx = find(obj.epochIDs == epochID);
        end

        function epoch = idx2epoch(obj, idx)
            epoch = obj.epochIDs(idx);
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

        function [stim, ID] = epoch2stim(obj, epochID)
            % EPOCH2STIM
            %
            % Description:
            %   Return the stimulus and stim ID for a given epochID
            %
            % Syntax:
            %   [stim, ID] = epoch2stim(obj, epochID)
            % -------------------------------------------------------------
            stimName = obj.stimulusNames(obj.epoch2idx(epochID));
            stim = ao.Stimuli.init(stimName);
            if nargout == 2
                ID = obj.stim{obj.stim.Stimulus == stim, "ID"};
            end
        end
        
        function epochs = stim2epochs(obj, stimID)
            % STIM2EPOCHS
            %
            % Description:
            %   Return the epoch IDs for a given stimulus
            % 
            % Syntax:
            %   epochs = obj.stim2epochs(stimName)
            %
            % Inputs:
            %   stimName        int or char
            %       Either the stim ID number or the stim name
            % -------------------------------------------------------------
            if ischar(stimID) || isstring(stimID)
                stimulus = ao.Stimuli.init(stimID);
                if stimulus == ao.Stimuli.Other
                    stimulus = ao.SpectralStimuli.(stimID);
                end
                epochs = obj.stim{obj.stim.Stimulus == stimulus, 'Epochs'};
            elseif isa(stimID, 'ao.Stimuli') || isa(stimID, 'ao.SpectralStimuli')
                epochs = obj.stim{obj.stim.Stimulus == stimID, 'Epochs'};
            elseif isnumeric(stimID)
                epochs = obj.stim{stimID, 'Epochs'};
            else
                error('AO.CORE.DATASET/STIM2EPOCHS: unrecognized input');
            end
            epochs = epochs{:};
            % epochs = setdiff(epochs, obj.omittedEpochs);
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
    
        function S = getCalibration(obj, calName)
            % GETCALIBRATION
            %
            % Syntax:
            %   S = obj.getCalibration(calName)
            % -------------------------------------------------------------

            if ~isa(obj.calibrations, 'containers.Map')
                obj.clearCalibrations();
                error('AO.CORE.DATSET/getCalibration: No calibrations found!');
            end
            
            if isKey(obj.calibrations, calName)
                S = obj.calibrations(calName);
            else
                error('AO.CORE.DATASET/getCalibration: %s not found!', calName);
            end
        end
    end
    
    % Initialization methods that may be run again with new values
    methods
        function loadROIs(obj, rois)
            % LOADROIS
            %
            %   obj.loadROIs(rois)
            %
            % Input:
            %   rois        filepath to imageJ rois or labelmatrix
            % -------------------------------------------------------------

            % If no input, guess the roi file name
            if nargin < 2 || isempty(rois)
                rois = normPath([obj.experimentDir, '\Analysis\',... 
                    obj.getLabel(), '_RoiSet.zip']);
            end

            if ischar(rois)
                rois = normPath(rois);
                if ~isfile(rois)
                    error('loadROIs: File not found: %s', rois);
                end
                if endsWith(rois, 'zip')
                    [~, obj.rois] = roiImportImageJ(rois,... 
                        [obj.imSize(1), obj.imSize(2)]);
                    % if ~isempty(obj.analysisRegion)
                    %     obj.rois = obj.pad(obj.rois);
                    % end
                elseif endsWith(rois, 'csv')
                    obj.rois = csvread(rois); %#ok<CSVRD> 
                end
                obj.roiFileName = rois;
            else
                obj.rois = rois;
            end
            
            if obj.reflectRois
                fprintf('Flipping ROIs vertically\n');
                obj.rois = flipud(obj.rois);
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
            if ~isempty(obj.roiFileName)
                if ~isempty(obj.experimentDir)
                    roiFile = strrep(obj.roiFileName, obj.baseDirectory, obj.experimentDir);
                else
                    roiFile = obj.roiFileName;
                end
                obj.loadROIs(roiFile);
            else
                warning('No roiFileName found, rois not reloaded!');
            end
        end

        function addWarningID(obj, IDs)
            obj.warningIDs = unique([obj.warningIDs, IDs]);
        end

        function loadAvgImage(obj, imPath)
            % LOADAVGIMAGE
            %
            % Description:
            %   Load a ROI average image
            %
            % Syntax:
            %   obj.loadAvgImage()
            % -------------------------------------------------------------
            obj.avgImage = imread(imPath);
        end

        function loadCalibration(obj, calName, calData)
            % LOADCALIBRATION
            %
            % Description:
            %   Load a .json calibration file
            %
            % Syntax:
            %   loadCalibration(obj, calName, calData)
            % -------------------------------------------------------------
            
            % For backwards compatibility:
            if isempty(obj.calibrations)
                obj.calibrations = containers.Map();
            end

            % Decide how to proceed based on whether input is file name
            if ischar(calData)
                    
                [~, ~, ext] = fileparts(calData);
                switch ext
                    case '.json'  % From saveCalibrationFile.m
                        obj.calibrations = loadjson(calData);
                    case '.mat'
                        obj.calibrations = load(calData);
                end
            else
                obj.calibrations(calName) = calData;
            end
                    
        end

        function addTransforms(obj, tforms, IDs)
            % ADDTRANSFORMS
            %
            % Description:
            %   Same as loadTransforms, but no clearTransforms
            %
            % Syntax:
            %   addTransforms(obj, tforms, IDs)
            %
            % Inputs:
            %   tforms          char OR [3 x 3 x N]
            %       SIFT output filename or matrix of N transforms
            % Optional inputs:
            %   IDs             array
            %       Epoch IDs corresponding to tforms
            % -------------------------------------------------------------
            if ischar(tforms)
                fName = tforms;
                tforms = readRigidTransform(fName);
                obj.tformFileName = fName;
            elseif isstruct(tforms) && isfield(tforms, 'Transformation')
                if isa(tforms.Transformation, 'affinetform2d')
                    tforms = tforms.Transformation.A';
                else
                    tforms = tforms.Transformation.A;
                end
            end

            for i = 1:numel(IDs)
                obj.transforms(num2str(IDs(i))) = ...
                    affine2d(squeeze(tforms(:,:,i)));
            end
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
                if isnumeric(tforms)
                    obj.transforms(num2str(IDs(i))) = ...
                        affine2d(squeeze(tforms(:, :, i)));
                else
                    obj.transforms(num2str(IDs(i))) = tforms(i);
                end
            end
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
                T = table(rangeCol(1, obj.numROIs), roiUIDs,...
                    'VariableNames', {'ID', 'UID'});
                obj.roiUIDs = T;
            elseif istable(roiUIDs)
                assert(height(roiUIDs) == obj.numROIs,...
                    'Number of UIDs must equal number of ROIs');
                assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'UID')),...
                    'roiUID table must have a column named UID');
                assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'ID')),...
                    'roiUID table must have a column named ID');

                obj.roiUIDs = roiUIDs; 
            else
                error('Invalid input!');
            end
            obj.roiUIDs = sortrows(obj.roiUIDs, 'ID');
        end

        function addRoiUID(obj, roiID, roiUID)
            % ADDROIUID
            %
            % Description:
            %   Assign a specific roi UID
            %
            % Syntax:
            %   obj.addRoiUID(roiID, roiUID)
            % -------------------------------------------------------------
            if isempty(obj.roiUIDs)
                obj.roiUIDs = table(rangeCol(1, obj.numROIs), repmat("", [obj.numROIs, 1]),...
                    'VariableNames', {'ID', 'UID'});
            end
            if nargin > 1
                assert(isstring(roiUID) & strlength(roiUID) == 3, 'roiUID must be string 3 characters long')
                obj.roiUIDs(obj.roiUIDs.ID == roiID, 'UID') = roiUID;
            end
        end

        function getRegisteredVideoNames(obj, registrationDate, analysisID)
            % GETREGISTEREDVIDEONAMES
            %
            % Description:
            %   Get the registered video names
            %
            % Syntax:
            %   getRegisteredVideoNames(obj, registrationDate, analysisID)
            %
            % Note:
            %   Supply registration date and ID if multiple registrations
            %   exist of a single video.
            %   Frame registration is used, not strip registration
            % -------------------------------------------------------------
            obj.registeredVideos = repmat("", size(obj.originalVideos));
            if nargin > 1 && ~isempty(registrationDate)
                registrationDate = datetime(registrationDate, 'Format', 'yyyyMMdd');
                analysisID = int2fixedwidthstr(analysisID, 3);
            
                for i = 1:numel(obj.originalVideos)
                    txt = obj.originalVideos(i);
                    txt = replace(txt, ".avi",...
                        sprintf('_%s_frame_ref000_%s.mat', registrationDate, analysisID));
                    ind = strfind(txt, "Vis");
                    txt = char(txt);
                    obj.registeredVideos(i) = [obj.baseDirectory, txt(ind-1:end)];
                    if ~isFile(obj.registeredVideos(i))
                        txt = replace(txt, "O.avi",...
                            sprintf('_%s_frame_ref000_%s.mat', registrationDate, analysisID));
                        ind = strfind(txt, "Vis");
                        txt = char(txt);
                        obj.registeredVideos(i) = [obj.baseDirectory, txt(ind-1:end)];
                    end
                end
            else
                for i = 1:numel(obj.originalVideos)
                    obj.registeredVideos(i) = normPath([obj.baseDirectory,... 
                        'Analysis', filesep, 'Videos', filesep, 'vis_',... 
                        int2fixedwidthstr(obj.epochIDs(i), 4), '.tif']);
                end
            end
        end
        
        function checkRegistrationReports(obj)
            % CHECKREGISTRATIONREPORTS
            % 
            % Description:
            %   Reads registration report to check for dropped frames
            %
            % Syntax:
            %   checkRegistrationReports(obj)
            % -------------------------------------------------------------
            obj.registrationReports = repmat("", size(obj.originalVideos));
            
            refFiles = ls([obj.baseDirectory, 'Ref']);
            refFiles = string(deblank(refFiles));
            refFiles = refFiles(contains(refFiles, 'motion') & endsWith(refFiles, 'csv'));

            for i = 1:numel(obj.epochIDs)
                if ~isempty(obj.extraHeader)
                    ind = find(contains(refFiles, ['ref_', int2fixedwidthstr(obj.epochIDs(i), 4)]));
                else
                    ind = find(contains(refFiles, [obj.extraHeader, '_ref_', int2fixedwidthstr(obj.epochIDs(i), 4)]));
                end
                if isempty(ind)
                    warning('Epoch %u - no registration file found!', obj.epochIDs(i));
                elseif numel(ind) > 1
                    warning('Epoch %u - %u registration files found!', obj.epochIDs(i), numel(ind));
                    disp(refFiles(ind));
                else
                    obj.registrationReports(i) = refFiles(ind);
                end
            end
            
            fprintf('Checking for frame registration failures...\n');
            obj.droppedFrames = cell(numel(obj.epochIDs), 1);
            for i = 1:numel(obj.epochIDs)
                obj.droppedFrames{i} = getDroppedFrames(...
                    obj.baseDirectory, obj.registrationReports(i));
                if ~isempty(obj.droppedFrames{i}) 
                    warning('Epoch %u dropped %u frames', obj.epochIDs(i), numel(obj.droppedFrames{i}));
                end
            end
        end
    end

    % Core data extraction methods
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
            
            % if ismember(epochID, obj.omittedEpochs)
            %     warning('Epoch %s is part of omitted epochs', ...
            %         value2string(epochID(ismember(epochID, obj.omittedEpochs))));
            %     if numel(epochID) == 1
            %         imStack = [];
            %         return
            %     end
            % end

            % First check the video cache
            if isKey(obj.videoCache, num2str(epochID))
                imStack = obj.videoCache(num2str(epochID));
                return
            end
            
            % If not in the cache, load the video
            idx = obj.epoch2idx(epochID);
            if isempty(idx)
                warning('No epochs matched %u', epochID);
            end

            if ismember(epochID, obj.warningIDs)
                warning('getEpochStack:SuspiciousEpoch',...
                    'Epoch %u has been marked to generate a warning, likely bad registration', epochID);
            end
            
            if ~isempty(obj.workingDirectory)
                videoName = normPath(strrep(char(obj.registeredVideos(idx)),... 
                    obj.baseDirectory, obj.workingDirectory));
            else
                videoName = normPath(char(obj.registeredVideos(idx)));
            end
            disp(videoName)
            tic;
            if endsWith(videoName, '.mat')
                S = load(videoName);
                imStack = S.imStack;
            elseif endsWith(videoName, '.tif')
                imStack = readTiffStack(videoName);
            elseif endsWith(videoName, '.avi')
                imStack = video2stack(videoName, 'Side', obj.imagingSide);
            end
            toc;
            
            % Remove the first blank frame
            imStack(:, :, 1) = [];
            
            % Crop, if necessary
            if ~isempty(obj.analysisRegion)
                imStack = obj.crop(imStack);
            end
            
            % Apply a transform, if necessary
            if ~isempty(obj.transforms) && isKey(obj.transforms, num2str(epochID)) ...
                    && ~isempty(obj.transforms(num2str(epochID)))
                disp('Applying transform');
                tform = obj.transforms(num2str(epochID));
                if isa(tform, 'affine2d')
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
                elseif isstruct(tform)
                    for i = 1:size(imStack,3)
                        imStack(:,:,i) = imwarp(imStack(:,:,i),... 
                            tform.SpatialRefObj, tform.Transformation,...
                            'OutputView', tform.SpatialRefObj);
                    end
                end
            end

            % Pad, if necessary
            if ~isempty(obj.analysisRegion)
                imStack = obj.pad(imStack);
            end

            % Flip, if necessary
            if obj.reflectVideos
                imStack = flipud(imStack);
            end

            % Add it to the video cache
            obj.videoCache(num2str(epochID)) = imStack;
            
            % Status update: print video name without file path
            videoName = strsplit(videoName, filesep);
            fprintf('Loaded %s\n', videoName{end});
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
            %   Decimate        Integer for downsampling (1/value)
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
            addParameter(ip, 'Decimate', [], @isnumeric);
            addParameter(ip, 'Norm', false, @islogical);
            addParameter(ip, 'KeepOmitted', false, @islogical);
            parse(ip, varargin{:});

            bkgdWindow = ip.Results.Bkgd;
            avgFlag = ip.Results.Average;
            smoothFac = ip.Results.Smooth;
            lowPassCutoff = ip.Results.LowPass;
            highPassCutoff = ip.Results.HighPass;
            bandPassCutoff = ip.Results.BandPass;
            normFlag = ip.Results.Norm;
            decimateValue = ip.Results.Decimate;
            keepOmitted = ip.Results.KeepOmitted;
            
            
            if cellfind(ip.UsingDefaults, 'Bkgd')
                iStim = obj.epoch2stim(epochID(1));
                bkgdWindow = iStim.bkgd();
            end
            
            if numel(epochID) == 1
                imStack = obj.getEpochStack(epochID);
                [signals, xpts] = roiResponses(imStack, obj.rois, bkgdWindow,...
                    'FrameRate', obj.frameRate, ip.Unmatched);
            else % Multiple epochs
                % if any(ismember(epochID, obj.omittedEpochs)) && ~keepOmitted
                %     warning('Skipping epoch %u', obj.omittedEpochs);
                %     epochID = setdiff(epochID, obj.omittedEpochs);
                % end
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

            if normFlag
                signals = signalNormalize(signals, bkgdWindow);
            end

            if ~isempty(decimateValue)
                mustBeInteger(decimateValue);
                xpts = decimate(xpts, decimateValue);
                [a,~,c] = size(signals);
                ypts = zeros(a,numel(xpts),c);
                if ismatrix(signals)
                    for i = 1:a 
                        ypts(i,:) = decimate(signals(i,:), decimateValue);
                    end
                else 
                    for i = 1:a 
                        for j = 1:c 
                            ypts(i,:,j) = decimate(signals(i,:,j), decimateValue);
                        end
                    end
                end
                signals = ypts;
            end                    

            if avgFlag && ndims(signals) == 3
                signals = mean(signals, 3);
            end
        end
    end

    % Derived data extraction methods
    methods 
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
            if ischar(epochIDs) || isa(epochIDs, 'ao.Stimuli')
                epochIDs = obj.stim2epochs(epochIDs);
            end
            imStack = [];
            for i = 1:numel(epochIDs)
                imStack = cat(4, obj.getEpochStack(epochIDs(i)));
            end
            imStack = squeeze(mean(imStack, 4));
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
            addParameter(ip, 'KeepOmitted', false, @islogical);
            % addParameter(ip, 'Smooth', [], @isnumeric);
            parse(ip, varargin{:});

            avgFlag = ip.Results.Average;
            bkgdWindow = ip.Results.Bkgd;
            keepOmitted = ip.Results.KeepOmitted;

            epochs = obj.stim2epochs(whichStim);
            iStim = obj.epoch2stim(epochs(1));

            % if any(ismember(epochs, obj.omittedEpochs)) && ~keepOmitted
            %     warning('Omitting epoch %s', ...
            %         value2string(epochs(ismember(epochs, obj.omittedEpochs))));
            %     epochs = setdiff(epochs, obj.omittedEpochs);
            % end

            % If background window not specified, get stimulus default
            if cellfind(ip.UsingDefaults, 'Bkgd')
                iStim = obj.epoch2stim(epochs(1));
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

        function avgStack = getStimulusAverage(obj, stimulusID)
            % GETSTIMULUSAVERAGE
            % 
            % Description:
            %   Get the average of all videos associated with a stimulus
            %
            % Syntax:
            %   avgStack = getStimulusAverage(obj, stimulusID);
            % -------------------------------------------------------------
            idx = find(obj.stimulusNames == obj.stimuliUsed(stimulusID));

            fprintf('Loading %u videos for %s...\n',... 
                numel(idx), obj.stimuliUsed(stimulusID));
            avgStack = [];
            for i = 1:numel(idx)
                % if ismember(idx(i), obj.omittedEpochs)
                %     continue
                % end
                avgStack = cat(4, avgStack, obj.getEpochStack(obj.epochIDs(idx(i))));
            end
            avgStack = squeeze(mean(avgStack, 4));
            
            if isempty(obj.imSize)
                obj.imSize = size(avgStack);
            end
        end        

        function dfStack = getEpochDfStacks(obj, epochIDs, bkgd, varargin)
            % GETEPOCHDFSTACKS
            %
            % Description:
            %   Convert fluorescence video pixels to dF
            %
            % Syntax:
            %   dfStack = obj.getEpochDfStacks(epochIDs, bkgd, varargin)
            %
            % Inputs:
            %   epochIDs        integer(s)
            %       Which epoch(s) to process
            %   bkgd            [1 x 2] integer
            %       Frame range for calculating baseline fluorescence
            %   Additional key/value inputs are passed to pixelDfStack
            %
            % See also:
            %   PIXELDFSTACK
            % -------------------------------------------------------------

            dfStack = [];
            for i = 1:numel(epochIDs)
                imStack = obj.getEpochStack(epochIDs(i));
                dfStack = cat(4, dfStack, pixelDfStack(imStack, bkgd, varargin{:}));
            end
        end

        function rois = getEpochROIs(obj, epochID)
            if ~obj.transformRois
                rois = obj.rois;
            else
                refObj = imref2d(size(obj.rois));
                rois = imwarp(obj.rois, refObj,...
                    obj.transforms(num2str(epochID)),...
                    'OutputView', refObj,...
                    'interp', 'nearest');
            end
        end
    end

    % Analysis methods
    methods 
        function makePrctleSnapshots(obj, IDs)
            if nargin < 2
                IDs = obj.epochIDs;
            end

            fPath = normPath([obj.experimentDir, filesep, 'Analysis', filesep, 'Snapshots', filesep]);
            progressbar();

            for i = 1:numel(IDs) 
                baseName = ['_', obj.getShortName(IDs(i)), '.png'];
                imStack = obj.getEpochStack(IDs(i));
                imStackD = im2double(imStack);
                progressbar(i / numel(IDs));
                imwrite(im2uint8(prctile(imStackD, 0.9, 3)),... 
                    [fPath, 'PCT', baseName], 'png');
            end
            progressbar(1);
        end

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
            
            fPath = normPath([obj.experimentDir, filesep, 'Analysis', filesep, 'Snapshots', filesep]);
            progressbar();
            for i = 1:numel(IDs) 
                baseName = ['_', obj.getShortName(IDs(i)), '.png'];
                imStack = obj.getEpochStack(IDs(i));
                imStackD = im2double(imStack);
                
                % TODO: omit dropped frames
                
                imSum = sum(imStackD, 3);
                imwrite(uint8(255 * imSum/max(imSum(:))),...
                    [fPath, 'SUM', baseName], 'png');
                imwrite(uint8(mean(imStack, 3)),...
                    [fPath, 'AVG', baseName], 'png');
                imwrite(uint8(max(imStack, [], 3)),... 
                    [fPath, 'MAX', baseName], 'png');
                imwrite(im2uint8(imadjust(std(imStackD, [], 3))),... 
                    [fPath, 'STD', baseName], 'png');
                progressbar(i / numel(IDs));
            end
            progressbar(1);
        end

        function I = getRoiIntensities(obj)
            % GETROIINTENSITIES
            %
            % Description:
            %   Get the average intensity of each ROI 
            %
            % Syntax:
            %   I = obj.getRoiIntensities();
            % -------------------------------------------------------------
            avgStack = zeros(obj.imSize(2), obj.imSize(1), numel(obj.epochIDs));
            for i = 1:numel(obj.epochIDs)
                avgStack(:, :, i) = mean(obj.getEpochStack(obj.epochIDs(i)), 3);
            end
            I = mean(roiDFF(avgStack, obj.rois, [], 'FrameRate', obj.frameRate), 2);
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
                
        function T = getRoiBaselines(obj)
            % GETROIBASELINES
            %
            % Description:
            %   Gets each ROIs mean and SD for each epochs baseline period
            %
            % Syntax:
            %   T = obj.getRoiBaselines()
            %
            % TODO: Option to specify specific ROIs
            % -------------------------------------------------------------
            
            avgF = zeros(numel(obj.epochIDs), obj.numROIs);
            stdF = zeros(numel(obj.epochIDs), obj.numROIs);
            stimNames = repmat("", [numel(obj.epochIDs), 1]);
            isBaseline = false(numel(obj.epochIDs), obj.numROIs);
            for i = 1:numel(obj.epochIDs)
                iStim = obj.epoch2stim(obj.epochIDs(i));
                stimNames(i) = string(iStim);
                iResp = roiDFF(obj.getEpochStack(obj.epochIDs(i)), obj.rois, []);
                if iStim.isBaseline()
                    isBaseline(i) = true;
                    avgF(i, :) = mean(iResp, 2);
                    stdF(i, :) = std(iResp, [], 2);
                else
                    bkgdRange = window2idx(iStim.bkgd());
                    avgF(i, :) = mean(iResp(:, bkgdRange), 2);
                    stdF(i, :) = std(iResp(:, bkgdRange), [], 2);
                end
            end
            
            T = table(obj.epochIDs', stimNames,...
                'VariableNames', {'EpochID', 'Stim'});
            for i = 1:obj.numROIs
                T.(sprintf('Roi %u', i)) = [avgF(:,i), stdF(:,i)];
            end
        end

        function QI = getStimulusQI(obj, stimName, varargin)
            % GETSTIMULUSQI
            % 
            % Description:
            %   Computes ROI quality indices from multiple repeats of stim
            %
            % Syntax:
            %   QI = obj.getStimulusQI(stimName, varargin)
            %
            % See also:
            %   QUALITYINDEX
            % -------------------------------------------------------------
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'StartFrame', 1, @isnumeric);
            addParameter(ip, 'EndFrame', 0, @isnumeric);
            addParameter(ip, 'EndStop', 0, @isnumeric);
            parse(ip, varargin{:});
            
            startFrame = ip.Results.StartFrame;
            endFrame = ip.Results.EndFrame;
            endStop = ip.Results.EndStop;

            IDs = obj.stim2epochs(stimName);
            if numel(IDs) == 1
                QI = NaN(obj.numROIs, 1);
                return
            end

            signals = obj.getEpochResponses(IDs, ip.Unmatched);
            if endFrame == 0
                endFrame = size(signals,2);
            end
            if endStop ~= 0
                endFrame = endFrame - endStop;
            end

            QI = qualityIndex(signals(:, startFrame:endFrame, :));
        end
    end
    
    methods (Access = protected)
        function y = getShortName(obj, epochID) %#ok<INUSL>
            % GETSHORTNAME
            %
            % Description:
            %   Naming convention used for saving snapshots and .tif files
            % -------------------------------------------------------------
            y = ['vis_', int2fixedwidthstr(epochID, 4)];
        end
        
        function filePath = getAttributesFilename(obj, epochID)
            % GETATTRIBUTESFILENAME
            %
            % Description:
            %   Get the name of the file with epoch attributes
            % -------------------------------------------------------------
            refFiles = ls([obj.baseDirectory, filesep, 'Ref']);
            refFiles = deblank(string(refFiles));
            refFiles = refFiles(contains(refFiles, '.txt'));
            refFiles = refFiles(contains(refFiles, ['ref_', int2fixedwidthstr(epochID,4)]));
            refFiles = refFiles(~contains(refFiles, 'params'));
            try
                filePath = [obj.baseDirectory, filesep, 'Ref', filesep, char(refFiles(1))];
            catch
                warning('getAttributesFilename:FileNotFound',...
                       'Attribut file was not found');
                filePath = [];
            end
        end

        function T = populateStimulusTable(obj)
            % POPULATESTIMULUSTABLE
            %
            % Description:
            %   Creates the stimulus table (obj.stim)
            % -------------------------------------------------------------
            [G, groupNames] = findgroups(obj.stimulusNames);
            numStimuli = numel(groupNames);
            N = splitapply(@numel, obj.stimulusNames, G);

            epochs = cell(numStimuli, 1);
            idx = cell(numStimuli, 1);

            for i = 1:numStimuli
                epochs{i} = obj.epochIDs(obj.stimulusNames == groupNames(i));
                idx{i} = find(obj.stimulusNames == groupNames(i));
            end

            stimuli = arrayfun(@(x) ao.Stimuli.init(x), groupNames);

            T = table((1:numel(groupNames))', N, stimuli, epochs, idx, ...
                'VariableNames', {'ID', 'N', 'Stimulus', 'Epochs', 'Index'});
        end

        function extractEpochAttributes(obj)
            % EXTRACTEPOCHATTRIBUTES
            % 
            % Description:
            %   Load epoch parameters from attributes file
            % -------------------------------------------------------------
            
            obj.pmtGains = zeros(numel(obj.epochIDs), 2);
            obj.stimulusNames = repmat("", [numel(obj.epochIDs), 1]);
            obj.stimulusFiles = repmat("", [numel(obj.epochIDs), 1]);
            obj.originalVideos = repmat("", [numel(obj.epochIDs), 1]);

            for i = 1:numel(obj.epochIDs)
                filePath = obj.getAttributesFilename(obj.epochIDs(i));
                if isempty(filePath)
                    continue
                end

                obj.stimulusFiles(i) = readProperty(filePath, 'Trial file name = ');
                txt = strsplit(obj.stimulusFiles(i), filesep);
                obj.stimulusNames(i) = txt{end};
                obj.pmtGains = str2double({...
                    readProperty(filePath, 'Reflectance PMT gain  = '),...
                    readProperty(filePath, 'Fluorescence PMT gain = ')});
            end

            [~, obj.stimuliUsed] = findgroups(obj.stimulusNames);
            obj.stim = obj.populateStimulusTable();
        end
    
        function imStack = crop(obj, imStack)
            % CROP
            % 
            % Syntax:
            %   imStack = obj.crop(imStack)
            % -------------------------------------------------------------
            if isempty(obj.analysisRegion)
                return
            end

            if ndims(imStack) == 3
                imStack = imStack(...
                    obj.analysisRegion(2,1):obj.analysisRegion(2,2),...
                    obj.analysisRegion(1,1):obj.analysisRegion(1,2), :); 
            elseif ndims(imStack) == 2
                imStack = imStack(...
                    obj.analysisRegion(2,1):obj.analysisRegion(2,2),...
                    obj.analysisRegion(1,1):obj.analysisRegion(1,2)); 
            end
        end

        function imStack = pad(obj, imStack)
            % CROP
            % 
            % Syntax:
            %   imStack = obj.pad(imStack)
            % -------------------------------------------------------------
            if isempty(obj.analysisRegion)
                return
            end
            
            prePad = [obj.analysisRegion(2,1) obj.analysisRegion(1,1)] - 1;
            postPad = [obj.imSize(2) - obj.analysisRegion(2,2), ...
                obj.imSize(1) - obj.analysisRegion(1,2)];
            if ndims(imStack) == 3
                prePad = [prePad, 0];
                postPad = [postPad, 0];
            end

            imStack = padarray(imStack, prePad, 0, 'pre');
            imStack = padarray(imStack, postPad, 0, 'post');
        end
    end
end 