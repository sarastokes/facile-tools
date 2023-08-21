classdef MultiDataset < handle
%#ok<*AGROW> 

    properties
        ups
        downs
        repCutoff = 0.4
        totalCutoff = 0.35
    end

    properties %(SetAccess = private)
        source
        location
        stimulusType

        xpts

        stimFilter 
        respProps

        StimTable 
        uidTable
        uidTable2
        datasetNames
        frameCounts
        roiCounts
        uniqueUUIDs
        roiResponses
        uidResponses
        allResponses

        repCorr
        hasMotion
        omitMatrix

        manualBad 
        manualGood
    end

    properties %(Transient, SetAccess = private)
        datasets 
        hasStim
    end

    properties (Dependent)
        numDatasets
        numUUIDs
        numReps

        colormap
    end

    properties (Hidden, Constant)
        FRAME_RATE = 25;
        INC_PROPS = {'FaceColor', [0.75, 0.75, 0.75], 'FaceAlpha', 0.4};
        DEC_PROPS = {'FaceColor', [0.55, 0.55, 0.55], 'FaceAlpha', 0.4};
    end

    methods 
        function obj = MultiDataset(source, location, stimulusType)
            obj.source = source;
            obj.location = location;
            assert(ismember(stimulusType, ["spectral", "spatial"]),...
                "stimulusType must be either spectral or spatial");
            obj.stimulusType = stimulusType;

            obj.uidResponses = aod.util.Parameters();
            obj.roiResponses = aod.util.Parameters();

            obj.collectDatasets();
        end
    end

    % Dependent set/get methods
    methods

        function value = get.numDatasets(obj)
            if isempty(obj.datasets)
                value = 0;
            else
                value = numel(obj.datasets);
            end
        end

        function value = get.numUUIDs(obj)
            if isempty(obj.uniqueUUIDs)
                value = 0;
            else
                value = numel(obj.uniqueUUIDs);
            end
        end

        function value = get.numReps(obj)
            if isempty(obj.StimTable)
                value = 0;
            else
                value = sum(obj.StimTable.NumReps);
            end
        end

        function value = get.colormap(obj)
            if ~isempty(obj.datasets)
                value = pmkmp(obj.numReps, 'CubicL');
            else
                value = [];
            end
        end
    end

    methods
        function ID = uid2id(obj, uuid)
            ID = find(obj.uniqueUUIDs == uuid);
        end

        function UUID = id2uid(obj, ID)
            UUID = obj.uniqueUUIDs(ID);
        end

        function signals = getRoiResponse(obj, dsetID, roiID)
            dsetData = obj.roiResponses{dsetID};
            signals = dsetData(roiID, :, :);
        end

        function uids = getGoodUIDs(obj)
            uids = obj.uidTable{obj.uidTable.Bad == 0, "UUID"};
        end

        function [signals, uuids] = getAvgResponses(obj)
            uuids = string.empty();
            signals = [];
            for i = 1:obj.numUUIDs
                if obj.uidTable.Bad(i) || nnz(obj.isValid(i, []))==0
                    continue
                end
                data = obj.getUuidResponse(obj.uidTable.UUID(i), false);
                idx = obj.isValid(i, []);
                if ~isempty(idx)
                    data = mean(data(idx,:), 1);
                    signals = cat(1, signals, data);
                    uuids = cat(1, uuids, obj.uidTable.UUID(i));
                end
            end
        end

        function signals = getUuidResponse(obj, uuid, omitNan)
            if nargin < 3
                omitNan = false;
            end

            if isnumeric(uuid)
                idx = uuid;
            else
                idx = find(obj.uniqueUUIDs == uuid);
            end

            if isempty(idx)
                warning('No UUID found matching %s!', uuid);
                signals = [];
                return
            end
            signals = squeeze(obj.allResponses(idx, :, :))';
            if omitNan
                idx = ~isnan(signals(:,1));
                signals = signals(idx, :);
            end
        end

        function setGoodROI(obj, ID)
            if isstring(ID)
                newID = zeros(size(ID));
                for i = 1:numel(ID)
                    newID(i) = obj.uid2id(ID(i));
                end
                ID = newID;
            end
            obj.manualGood = cat(2, obj.manualGood, ID);
        end

        function setBadROI(obj, ID)
            if isstring(ID)
                newID = zeros(size(ID));
                for i = 1:numel(ID)
                    newID(i) = obj.uid2id(ID(i));
                end
                ID = newID;
            end
            obj.manualBad = cat(2, obj.manualBad, ID);
            obj.uidTable.Bad(ID) = true;
        end

        function plotUuidErr(obj, uuid, varargin)
            ip = aod.util.InputParser();
            addParameter(ip, 'Parent', [], @ishandle);
            addParameter(ip, 'All', false, @islogical);
            addParameter(ip, 'Cutoff', obj.repCutoff, @isnumeric);
            addParameter(ip, 'LineProp', '-b', @ischar);
            addParameter(ip, 'Norm', false, @islogical);
            parse(ip, varargin{:});

            if isempty(ip.Results.Parent)
                ax = axes('Parent', figure()); hold on;
            else
                ax = ip.Results.Parent;
            end
            hold(ax, 'on');
            thresh = ip.Results.Cutoff;
            lineProp = ip.Results.LineProp;
            normFlag = ip.Results.Norm;
                
            if isnumeric(uuid)
                ID = uuid;
                uuid = obj.id2uid(ID);
            else
                uuid = upper(uuid);
                ID = obj.uid2id(uuid);
            end

            data = obj.getUuidResponse(uuid);
            if isempty(data) || nnz(obj.isValid(ID, [], thresh)) == 0
                warning('No valid data!\n');
                return
            end

            if ip.Results.All
                co = obj.colormap;
                if normFlag
                    data = data ./ max(abs(data), [], 2, 'omitnan');
                end
                plot(ax, obj.xpts, mean(data(obj.isValid(ID, [], thresh),:), 1),... 
                    'k', 'LineWidth', 1.5);
                for i = 1:size(data, 1)
                    if obj.isValid(ID, i)
                        plot(ax, obj.xpts, data(i,:),... 
                            'Color', co(i,:), 'LineWidth', 0.7);
                    end
                end
            else
                data = data(obj.isValid(ID, [], thresh), :);
                if normFlag
                    data = data ./ max(abs(data), [], 2, 'omitnan');
                end
                shadedErrorBar(obj.xpts, data,... 
                    {@(x)mean(x, 1, 'omitnan'), @(x)std(x, [], 1, 'omitnan')},...
                    'lineprops', {lineProp, 'LineWidth', 1, 'Parent', ax});
            end
            xlim(ax, [min(obj.xpts), max(obj.xpts)]);
            addZeroBarIfNeeded(ax);
            roundYAxisLimits(ax, 0.5);
            if ax.YLim(1) > 0
                ax.YLim(1) = 0;
            end
            if ~isempty(obj.ups)
                addStimPatch(ax, obj.ups, obj.INC_PROPS{:});
            end
            if ~isempty(obj.downs)
                addStimPatch(ax, obj.downs, obj.DEC_PROPS{:});
            end
            title(ax, uuid);
            showGrid(ax, 'y');
            reverseChildOrder(ax);
            if isempty(ip.Results.Parent)
                figPos(ax.Parent, 0.5, 0.5);
            end
        end

        function [avgR, R] = getUuidCorr(obj, uuid)            
            if isnumeric(uuid)
                uuid = obj.uidTable.UUID(uuid);
            end
            data = obj.getUuidResponse(uuid);

            R = corrcoef(data');
            avgR = zeros(1,size(R,1));
            for i = 1:size(R,1)
                iR = R(i,:);
                avgR(i) = median(iR(iR<1), 'omitnan');
            end
        end
    end

    methods
        function setStimFilter(obj, stimFilter)
            obj.stimFilter = stimFilter;

            obj.sortByFilter();
        end

        function acceptFilter(obj)
            obj.datasets = obj.datasets(obj.hasStim);
            obj.datasetNames = obj.datasetNames(obj.hasStim);
        end

        function checkDirectories(obj)
            for i = 1:numel(obj.datasets)
                fprintf('%s = %s\n', obj.datasetNames(i), obj.datasets(i).experimentDir);
            end
        end

        function setWorkingDirectory(obj, dsetID, filePath)
            obj.datasets(dsetID).setWorkingDirectory(filePath);
        end

        function collectResponses(obj, varargin)
            obj.respProps = varargin;
            obj.roiResponses = cell(0,1);
            obj.frameCounts = zeros(1, height(obj.StimTable));
            obj.roiCounts = zeros(1, height(obj.StimTable));
            for i = 1:height(obj.StimTable)
                signals = obj.datasets(obj.StimTable.ID(i)).getStimulusResponses(...
                    obj.StimTable.Stimulus(i), varargin{:});
                obj.roiResponses = cat(1, obj.roiResponses, signals);
                obj.frameCounts(i) = size(signals, 2);
                obj.roiCounts(i) = size(signals, 1);
            end
            if numel(unique(obj.frameCounts)) > 1
                warning('Multiple values for frame counts!');
            end
            obj.xpts = getX2(min(obj.frameCounts), obj.FRAME_RATE);
        end

        function go(obj)
            if isempty(obj.roiResponses)
                error('Cannot proceed until collectResponses is run!');
            end
            obj.collectUUIDs();
            obj.assignResponses();
            obj.computeQualityIndex();
            obj.getMotionROIs();
            obj.getOmittedROIs();
            obj.calcAdjustedQI();
        end

        function setStimWindows(obj, ups, downs)
            if nargin < 2
                [obj.ups, obj.downs] = obj.datasets(1).getModWindows(...
                    obj.StimTable.Stimulus(1));
            else
                obj.ups = ups; 
                obj.downs = downs;
            end
        end

        function getMotionROIs(obj, motionCutoff)
            if nargin < 2
                motionCutoff = 0.9;
            end
            
            obj.hasMotion = zeros(obj.numUUIDs, obj.numReps);

            for i = 1:obj.numUUIDs
                for j = 1:obj.numReps
                    if ~isnan(obj.allResponses(i,:,j))
                        data = signalHighPassFilter(obj.allResponses(i,:,j), 0.1, 25.3);
                        [p, f] = signalPowerSpectrum(data, 25);
                        maxVal = p(findclosest(f, 0.22));
                        maxPcts = maxVal/max(p);
    
                        if maxPcts > motionCutoff
                            fprintf('Motion: %s rep %u (%.2f)\n', obj.uniqueUUIDs(i), j, maxPcts);
                            obj.hasMotion(i,j) = 1;
                        end

                    end
                end
            end
            fprintf('Found %u motion ROIs\n', nnz(obj.hasMotion(:)));
        end

        function getOmittedROIs(obj, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'RepCutoff', obj.repCutoff, @isnumeric);
            addParameter(ip, 'TotalCutoff', obj.totalCutoff, @isnumeric);
            addParameter(ip, 'KeepSingles', false, @islogical);
            parse(ip, varargin{:});

            repCutoffA = ip.Results.RepCutoff;
            totalCutoffA = ip.Results.TotalCutoff;
            keepSingles = ip.Results.KeepSingles;

            obj.getRepCorr();

            obj.omitMatrix = zeros(obj.numUUIDs, obj.numReps);
            for i = 1:obj.numUUIDs
                if ~isempty(obj.manualBad) && ismember(obj.manualBad)
                    obj.omitMatrix(i,:) = 1;
                    continue
                end
                if keepSingles && obj.uidTable.Reps == 1
                    for j = 1:obj.numReps
                        obj.omitMatrix(i,j) = ~obj.isValid(i,1,j);
                    end
                else
                    for j = 1:obj.numReps
                        if ~obj.isValid(i, j, repCutoffA)
                            obj.omitMatrix(i,j) = 1;
                        end
                    end
                end
            end

            obj.uidTable.Omit = sum(obj.omitMatrix, 2);
            obj.uidTable.Bad = obj.uidTable.Omit == obj.numReps | ...
                obj.uidTable.Corr < totalCutoffA;

            fprintf('%u of %u UUIDS omitted (%.2f pct)\n',...
                nnz(obj.uidTable.Bad), obj.numUUIDs, nnz(obj.uidTable.Bad)/obj.numUUIDs);
        end

        function tf = isValid(obj, uid, rep, cutoff)
            if nargin < 4
                cutoff = obj.repCutoff;
            end
            if isempty(uid)
                uid = 1:obj.numUUIDs;
            end
            if isempty(rep)
                rep = 1:obj.numReps;
            end
            tf = false(numel(uid), numel(rep));
            for i = 1:numel(uid)
                % ! return to fix!!
                %if obj.hasBad && obj.uidTable.Bad
                %    tf(i,:) = false;
                %    continue
                %end
                for j = 1:numel(rep)
                    if isnan(obj.repCorr(uid(i), rep(j)))...
                            || obj.repCorr(uid(i),rep(j)) < cutoff... 
                            || obj.hasMotion(uid(i),rep(j))
                        tf(i,j) = false;
                    else
                        tf(i,j) = true;
                    end
                end
            end
        end

        function tf = hasBad(obj)
           tf = any(ismember("Bad", obj.uidTable.Properties.VariableNames));
        end
    end

    methods %(Access = private)
        function rowIdx = getDsetRows(obj, dsetID)
            if dsetID == 1
                rowIdx = 1:obj.StimTable.NumReps(1);
            else
                rowStart = sum(obj.StimTable.NumReps(1:dsetID-1)) + 1;
                rowEnd = rowStart + obj.StimTable.NumReps(dsetID)-1;
                rowIdx = rowStart:rowEnd;
            end
        end

        function collectDatasets(obj)
            obj.datasetNames = obj.getLoggedDatasets(obj.source, obj.location, obj.stimulusType);
            if isempty(obj.datasets)
                for i = 1:numel(obj.datasetNames)
                    S = load(obj.datasetNames(i) + ".mat");
                    obj.datasets = cat(1, obj.datasets, S.(obj.datasetNames(i)));
                end
            end
            fprintf('Collected %u datasets\n', obj.numDatasets);
        end

        function sortByFilter(obj)
            obj.hasStim = false(1, obj.numDatasets);
            dsetCounter = 0;
            allReps = []; allStimNames = []; 
            allDsets = []; allDsetNames = [];
            for i = 1:obj.numDatasets 
                stimuliUsed = string(obj.datasets(i).stim.Stimulus);
                idx = find(obj.stimFilter(stimuliUsed));
                if isempty(idx)
                    continue
                end
                obj.hasStim(i) = true;
                dsetCounter = dsetCounter + 1;
                allDsets = cat(1, allDsets, repmat(dsetCounter, [numel(idx), 1]));
                allDsetNames = cat(1, allDsetNames, repmat(obj.datasetNames(i), [numel(idx), 1]));
                allStimNames = cat(1, allStimNames, stimuliUsed(idx));
                allReps = cat(1, allReps, obj.datasets(i).stim.N(idx));
            end
            obj.StimTable = table(allDsets, allDsetNames, allStimNames, allReps,...
                'VariableNames', {'ID', 'Dataset', 'Stimulus', 'NumReps'});
            fprintf('%u of %u matched stimulus filter\n', nnz(obj.hasStim), obj.numDatasets);
        end

        function assignResponses(obj)
            obj.allResponses = nan(obj.numUUIDs, min(obj.frameCounts), obj.numReps);
            for i = 1:obj.numUUIDs
                dsetIDs = obj.uidTable2{obj.uidTable2.UUID == obj.uniqueUUIDs(i), "ID"};
                for j = 1:numel(dsetIDs)
                    roiID = obj.datasets(dsetIDs(j)).uid2roi(obj.uniqueUUIDs(i));
                    rowIdx = obj.getDsetRows(dsetIDs(j));
                    obj.allResponses(i, :, rowIdx) = obj.getRoiResponse(dsetIDs(j), roiID);
                end
            end
        end

        function collectUUIDs(obj)
            allUUIDs = string.empty;
            dsetID = []; nReps = [];
            for i = 1:obj.numDatasets
                iUUID = obj.datasets(i).roiUIDs.UID;
                dsetID = [dsetID; repmat(i, [numel(iUUID), 1])]; 
                allUUIDs = [allUUIDs; obj.datasets(i).roiUIDs.UID]; 
                nReps = [nReps; repmat(obj.StimTable.NumReps(i), [numel(iUUID), 1])];
            end
            obj.uidTable2 = table(dsetID, allUUIDs, nReps, 'VariableNames', {'ID', 'UUID', 'N'});
            blankIdx = find(obj.uidTable2.UUID == "");
            if ~isempty(blankIdx)
                fprintf('%u blank UUIDs found!\n', numel(blankIdx));
                obj.uidTable2(blankIdx,:) = [];
            end
            
            [g, groupNames] = findgroups(obj.uidTable2.UUID);
            N = splitapply(@sum, obj.uidTable2.N, g);
            [~, idx] = sort(groupNames);
            obj.uniqueUUIDs = groupNames;

            obj.uidTable = table(obj.uniqueUUIDs, zeros(obj.numUUIDs, 1), N(idx),...
                'VariableNames', {'UUID', 'N', 'Reps'});
            for i = 1:height(obj.uidTable)
                obj.uidTable.N(i) = numel(find(allUUIDs == obj.uidTable.UUID(i)));
            end

            figure(); hold on; grid on;
            binEdges = 0:obj.numDatasets;
            histogram(obj.uidTable.N, 'BinEdges', binEdges+0.5);
            xlabel('Number of Presentations');
            ylabel('Number of UUIDs');
            title(sprintf('%u UUIDs', obj.numUUIDs));
            xticks(1:obj.numDatasets);
            figPos(gcf, 0.7, 0.7);

            figure(); hold on; grid on;
            histogram(obj.uidTable.Reps, 'NumBins', obj.numReps);
            xlabel('Number of Repeats');
            ylabel('Number of UUIDs');
            xticks(1:obj.numReps);
            title(sprintf('%u UUIDs', obj.numUUIDs));
            figPos(gcf, 0.7, 0.7);
        end

        function QI = computeQualityIndex(obj)
            QI = zeros(obj.numUUIDs,1);
            for i = 1:obj.numUUIDs
                if obj.uidTable.Reps(i) == 1
                    QI(i) = NaN;
                    continue
                end
                signals = obj.getUuidResponse(obj.uniqueUUIDs(i), true)';
                QI(i) = qualityIndex(reshape(signals, [1, size(signals,1), size(signals,2)]));
            end

            obj.uidTable.QI = QI;
            thresholds = 0.6:0.1:0.9;
            realQI = QI(~isnan(QI));
            for i = 1:numel(thresholds)
                fprintf('%u UUIDs above %.1f\n', ...
                    nnz(realQI > thresholds(i)), thresholds(i));
            end
            fprintf('%u UUIDs have NaN QI, %u UUIDs total\n', ...
                numel(QI)-numel(realQI), obj.numUUIDs);
        end

        function calcAdjustedQI(obj)
            QI = zeros(obj.numUUIDs, 1);
            for i = 1:obj.numUUIDs
                if obj.uidTable.Reps(i) == 1
                    QI(i) = NaN;
                    continue
                end
                signals = obj.getUuidResponse(obj.uniqueUUIDs(i), true)';
                signals = signals ./ max(abs(signals), [], 2, 'omitnan');
                idx = [];
                for j = 1:obj.numReps
                    if ~isnan(signals(j, 1)) || obj.repCorr(i,j) > obj.repCutoff
                        idx = [idx; j];
                    end
                end
                signals = signals(idx,:);
                if size(signals, 1) == 1
                    QI(i) = NaN;
                    continue
                end
                QI(i) = qualityIndex(reshape(signals,... 
                    [1, size(signals,1), size(signals,2)]));
                obj.uidTable.QIadj = QI;
            end
        end

        function getRepCorr(obj)
            obj.repCorr = zeros(obj.numUUIDs, obj.numReps);
            for i = 1:obj.numUUIDs
                obj.repCorr(i,:) = obj.getUuidCorr(i);
            end
            obj.uidTable.Corr = median(obj.repCorr, 2, 'omitnan');
            obj.uidTable.CorrA = mean(obj.repCorr, 2, 'omitnan');
        end
    end

    methods (Static)
        function dsets = getLoggedDatasets(source, location, stimulusType)
            % GETLOGGEDDATASETS
            if source == 838 && location == "ODR"
                if stimulusType == "spectral"
                    dsets = [...
                        "MC00838_ODR_20211229B";
                        "MC00838_ODR_20220316B";
                        "MC00838_ODR_20220321B";
                        "MC00838_ODR_20220330B";
                        "MC00838_ODR_20220524B";
                        "MC00838_ODR_20220606B";
                        "MC00838_ODR_20220613B";
                        "MC00838_ODR_20220708B";
                        "MC00838_ODR_20220713B";
                        "MC00838_ODR_20220825B";
                    ];
                elseif stimulusType == "spatial"
                    dsets = [...
                        "MC00838_ODR_20211229A";
                        "MC00838_ODR_20220321A";
                        "MC00838_ODR_20220330A";
                        "MC00838_ODR_20220524A";
                        "MC00838_ODR_20220606A";
                        "MC00838_ODR_20220613A";
                        "MC00838_ODR_20220708A";
                        "MC00838_ODR_20220713A";
                    ];
                end
            elseif source == 851 && location == "ODR"
            elseif source == 851 && location == "OSR"
                if stimulusType == "spectral"
                    dsets = [...
                        "MC00851_OSR_20211228B",...
                        "MC00851_OSR_20220105B",...
                        "MC00851_OSR_20220125B",...
                        "MC00851_OSR_20220222B",...
                        "MC00851_OSR_20220308B",...
                        "MC00851_OSR_20220315B",...
                        "MC00851_OSR_20220322B",...
                        "MC00851_OSR_20220329B",...
                        "MC00851_OSR_20220405B",...
                        "MC00851_OSR_20220412B",...
                        "MC00851_OSR_20220426B",...
                        "MC00851_OSR_20220523B",...
                        "MC00851_OSR_20220614B",...
                        "MC00851_OSR_20220719B",...
                    ];
                end
            end
        end

        function demo838()
            % Instantiate the object
            obj = MultiDataset(838, "ODR", "spectral");

            % Assign a stimulus filter
            stimFilter = @(x) contains(x, "LuminanceChirp") & contains(x, "160t");
            obj.setStimFilter(stimFilter);
            obj.acceptFilter();

            % Ensure expeirment directories are correct
            obj.checkDirectories();
            if ispc
                obj.setWorkingDirectory(1,... 
                    'C:\Users\sarap\Dropbox\Postdoc\Data\AO\MC00838_20220524\');
            else
                obj.setWorkingDirectory(1,...
                    '/Users/sarap/Dropbox/Postdoc/Data/AO/MC00838_20220524');
            end

            % Collect the responses sorted by experient-level ROI ID
            obj.collectResponses([200 498], 'Smooth', 100);

            % Run all the other analyses
            obj.go();

            % Set the stimulus window for plotting (optional)
            obj.setStimWindows();
            obj.ups = [obj.ups(1), obj.ups(end)];
            obj.downs = [];
        end

        function CHIRP851 = demo851()
            CHIRP851 = MultiDataset(851, "OSR", "spectral");

            stimFilter = @(x) contains(x, "LuminanceChirp") & contains(x, "10p") & contains(x, "160t");
            CHIRP851.setStimFilter(stimFilter);
            CHIRP851.acceptFilter();

            CHIRP851.setWorkingDirectory(2,... 
                'C:\Users\sarap\Dropbox\Postdoc\Data\AO\MC00851_20220426\');

            CHIRP851.collectResponses([200 498], 'Smooth', 100);

            % Set the stimulus window for plotting (optional)
            CHIRP851.setStimWindows();
            CHIRP851.ups = [CHIRP851.ups(1), CHIRP851.ups(end)];
            CHIRP851.downs = [];

            CHIRP851.go();
        end
    end
end 