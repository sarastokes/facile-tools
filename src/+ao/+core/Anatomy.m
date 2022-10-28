classdef Anatomy < handle

    properties (SetAccess = private)
        baseDirectory
        epochIDs
        source 
        experimentDate
        
        registrationDate

        imageNames
        refImageNames
        
        droppedFrames
        translation
    end

    properties (Hidden, Transient)
        videoCache
    end

    methods
        function obj = Anatomy(expDate, source, baseDir, epochIDs, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'RegistrationDate', '', @ischar);
            addParameter(ip, 'CheckDroppedFrames', true, @islogical);
            parse(ip, varargin{:});
            obj.registrationDate = ip.Results.RegistrationDate;
            
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');
            if ~isa(source, 'ao.NHP')
                obj.source = ao.NHP.init(source);
            else
                obj.source = source;
            end
            obj.baseDirectory = baseDir;
            if ~strcmp(obj.baseDirectory(end), filesep)
                obj.baseDirectory = [obj.baseDirectory, filesep];
            end
            obj.epochIDs = epochIDs;

            obj.videoCache = containers.Map();

            obj.getImageNames();
            obj.loadTranslation();

            obj.droppedFrames = cell(numel(epochIDs), 1);
            if ip.Results.CheckDroppedFrames
                obj.checkDroppedFrames();
            end
        end

        function im = getVideoImage(obj, ID, varargin)
            % GETVIDEOIMAGE
            if isKey(obj.videoCache, num2str(ID))
                imStack = obj.videoCache(num2str(ID));
            else
                imStack = obj.loadVideo(ID, varargin{:});
                obj.videoCache(num2str(ID)) = imStack;
            end
            im = squeeze(mean(imStack, 3));
        end

        function im = loadImage(obj, ID, varargin)
            % LOADIMAGE
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Raw', false, @islogical);
            addParameter(ip, 'Frame', false, @islogical);
            addParameter(ip, 'Log', false, @islogical);
            parse(ip, varargin{:});

            idx = find(obj.epochIDs == ID);
            if ip.Results.Log
                imName = char(strrep(obj.imageNames(idx), '.tif', '_log.tif'));
            else
                imName = char(obj.imageNames(idx));
            end
            
            if ip.Results.Frame
                imName = strrep(imName, 'strip', 'frame');
            end
            
            im = imread(imName);
            if ~ip.Results.Raw && ~isempty(obj.translation) && ismember(ID, obj.translation(:, 1))
                idx = find(obj.translation(:, 1) == ID);
                if nnz(obj.translation(idx, 2:3)) > 0
                    im = imtranslate(im, obj.translation(idx, 2:3));
                end
            end
        end

        function im = loadRefImage(obj, ID, varargin)
            % LOADREFIMAGE
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Raw', false, @islogical);
            addParameter(ip, 'Frame', false, @islogical);
            parse(ip, varargin{:});

            imName = char(obj.refImageNames(obj.epochIDs == ID));
            if ip.Results.Frame
                imName = strrep(imName, 'strip', 'frame');
            end
            im = imread(imName);
            if ~ip.Results.Raw && ~isempty(obj.translation) && ismember(ID, obj.translation(:, 1))
                idx = find(obj.translation(:, 1) == ID);
                if nnz(obj.translation(idx, 2:3)) > 0
                    im = imtranslate(im, obj.translation(idx, 2:3));
                end
            end
        end

        function imStack = loadVideo(obj, epochID, varargin)
            % LOADVIDEO
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Raw', false, @islogical);
            addParameter(ip, 'Log', false, @islogical);
            parse(ip, varargin{:});
            
            videoName = [obj.baseDirectory, 'Analysis\Videos\',...
                'vis_', int2fixedwidthstr(epochID, 4), '.tif'];
            disp(videoName)
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            ts = TIFFStack(videoName);
            imStack = ts(:, :, :);

            % Remove the first frame and all dropped frames
            allDropped = obj.droppedFrames{obj.epoch2idx(epochID)};
            imStack(:, :, [1; allDropped]) = [];
            if ~isempty(allDropped)
                fprintf('%s - dropped %u of %u frames\n',... 
                    int2fixedwidthstr(epochID, 4), numel(allDropped),... 
                    size(imStack, 3) + numel(allDropped) + 1);
            end

            if ~ip.Results.Raw && ~isempty(obj.translation) && ismember(epochID, obj.translation(:, 1))
                idx = find(obj.translation(:, 1) == epochID);
                if nnz(obj.translation(idx, 2:3)) > 0
                    imStack = imtranslate(imStack, [obj.translation(idx, 2:3), 0]);
                end
            end
        end

        function loadTranslation(obj)
            % LOADTRANSLATION
            analysisDir = [obj.baseDirectory, 'Analysis\'];
            fileName = ['transforms_', char(obj.experimentDate), '.txt'];
            if exist([analysisDir, fileName], 'file')
                obj.translation = dlmread([analysisDir, fileName]);
            end
        end
    end

    methods 
        function idx = epoch2idx(obj, epochID)
            idx = find(obj.epochIDs == epochID);
        end

        function epoch = idx2epoch(obj, idx)
            epoch = obj.epochIDs(idx);
        end
    end

    methods % (Access = private)

        function getImageNames(obj)
            % GETIMAGENAMES
            visDir = [obj.baseDirectory, 'Vis', filesep];
            refDir = [obj.baseDirectory, 'Ref', filesep];

            fVis = ls(visDir);
            fVis = deblank(string(fVis));
            
            fRef = ls(refDir);
            fRef = deblank(string(fRef));

            nhp = char(obj.source);
            baseStr = [nhp(end-2:end), '_', char(obj.experimentDate), '_Vis_'];

            obj.imageNames = repmat("", [numel(obj.epochIDs), 1]);
            obj.refImageNames = repmat("", [numel(obj.epochIDs), 1]);
            
            for i = 1:numel(obj.epochIDs)
                % 1) Get the fluorescence image
                videoStr = [baseStr, int2fixedwidthstr(obj.epochIDs(i), 4)];    
                idx = find(startsWith(fVis, videoStr) & endsWith(fVis, '.tif')... 
                    & contains(fVis, 'strip') & ~contains(fVis, 'log'));
                if isempty(idx)  % Just for 2Mar2020 - remove after fixing
                    idx = find(startsWith(fVis, lower(videoStr)) & endsWith(fVis, '.tif')... 
                        & contains(fVis, 'strip') & ~contains(fVis, 'log'));
                end
                
                % Check for registrationDate, if provided
                if ~isempty(obj.registrationDate)
                    idx = intersect(idx, find(contains(fVis, obj.registrationDate)));
                    if isempty(idx)
                        error('epoch %u - no registered VIS images for %s',... 
                            obj.epochIDs(i), obj.registrationDate);
                    end
                end
                
                if numel(idx) > 1
                    warning('epoch %u - found %u registered VIS images, using the first',... 
                        obj.epochIDs(i), numel(idx));
                    idx = idx(1);
                end
                obj.imageNames(i) = [visDir, char(fVis(idx))];

                % 2) Get the reflectance image
                videoStr = strrep(videoStr, 'Vis', 'ref');
                idx = find(startsWith(fRef, videoStr) & endsWith(fRef, '.tif')... 
                    & contains(fRef, 'strip'));
                % Check for registrationDate, if provided
                if ~isempty(obj.registrationDate)
                    idx = intersect(idx, find(contains(fVis, obj.registrationDate)));
                    if isempty(idx)
                        error('epoch %u - no registered REF images for %s',... 
                            obj.epochIDs(i), obj.registrationDate);
                    end
                end
                % Check for duplicates
                if numel(idx) > 1
                    warning('epoch %u - found %u registered REF images, using the first',... 
                        obj.epochIDs(i), numel(idx));
                    idx = idx(1);
                end
                obj.refImageNames(i) = [refDir, char(fRef(idx))];
            end
        end

        function checkDroppedFrames(obj)
            % CHECKDROPPEDFRAMES
            for i = 1:numel(obj.epochIDs)
                obj.droppedFrames{i} = getDroppedFrames(...
                    obj.baseDirectory, obj.epochIDs(i),... 
                    [num2str(double(obj.source)), '_', char(obj.experimentDate)]);
            end
        end
    end

end 