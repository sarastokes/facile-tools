classdef DatasetLED2 < ao.core.Dataset

    properties 
        ledTables 
        frameTables
        frameRates
        ledStimNames
        stimWindows
    end

    properties (Hidden, Dependent)
        avgFrameRate
    end

    methods 
        function obj = DatasetLED2(expDate, source, epochIDs, baseDir, varargin)
            obj@ao.core.Dataset(expDate, source, epochIDs, NaN, baseDir, varargin{:});
            
            obj.frameTables = containers.Map();
            obj.ledTables = containers.Map();
            obj.stimWindows = zeros(numel(obj.epochIDs), 2);

            obj.loadFrameTraces();
            obj.loadLedTraces();
        end

        function value = get.avgFrameRate(obj)
            if ~isnan(obj.frameRates)
                value = mean(obj.frameRates, 'omitnan');
            else
                value = obj.frameRate;
            end    
        end

        function getStimuli(obj)
            % GETSTIMULI
            %
            % Description:
            %   Load stimuli from stimulus file names
            %
            % Syntax:
            %   getStimuli(obj)
            %
            % -------------------------------------------------------------
            stimList = [];
            for i = 1:numel(obj.stimulusNames)
                stimList = cat(1, stimList, ao.SpectralStimuli.init(obj.stimulusNames(i)));
            end
            obj.ledStimNames = stimList;
            obj.stim = obj.populateStimulusTable();
        end

        function setStimuli(obj, stimNames)
            % SETSTIMULI
            %
            % Syntax:
            %   obj.setStimuli(stimNames)
            % -------------------------------------------------------------
            if size(stimNames, 1) == 1
                stimNames = stimNames';
            end
            if numel(stimNames) ~= numel(obj.epochIDs)
                warning('Number of stimuli (%u) does not match number of epochs (%u)',...
                    numel(stimNames), numel(obj.epochIDs));
            end
            obj.ledStimNames = stimNames;
            obj.stim = obj.populateStimulusTable();
        end
    end
    
    
    % Modified/overwritten public methods
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

        function imStack = getEpochStack(obj, epochID)
            % GETEPOCHSTACK
            %
            % Extends:
            %   ao.core.Dataset/getEpochStack
            % ---------------------------------------------------------
            imStack = getEpochStack@ao.core.Dataset(obj, epochID);
            
            % Get the true frame count
            iStim = obj.epoch2stim(epochID);
            nFrames = iStim.frames();
            % Clip off the extra frames
            try
                imStack = imStack(:,:,1:nFrames);
            catch
                warning('Epoch %u size did not match nFrames (%u)', epochID, nFrames);
            end
            
        end
        
        function [A, xpts] = getEpochResponses(obj, epochID, varargin)
            % GETEPOCHRESPONSES
            % 
            % Syntax:
            %   [A, xpts] = obj.getEpochResponses(epochID, varargin)
            %
            % Extends:
            %   ao.core.Dataset/getEpochResponses
            % ---------------------------------------------------------
            A = [];
            for i = 1:numel(epochID)
                iStim = obj.ledStimNames(obj.epoch2idx(epochID(i)));
                [Ai, xpts] = getEpochResponses@ao.core.Dataset(obj, epochID(i),...
                    varargin{:}, 'Stim', iStim);
                A = cat(3, A, Ai);
            end
        end
    
        function stim = getEpochTrace(obj, epochID, whichLED, frames)
            % GETEPOCHTRACE
            % 
            % Syntax:
            %   Returns red LED frame trace for specified epoch IDs
            % -------------------------------------------------------------
            if nargin < 4
                frames = true;
            end
            if nargin < 3
                whichLED = 4;
            end
            
            stim = [];
            for i = 1:numel(epochID)
                if frames
                    T = obj.frameTables(epochID(i));
                else
                    T = obj.ledTables(epochID(i));
                end
                try
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
                catch
                    warning('Mismatch in stim length for epoch %u\n', epochID(i));
                end
            end
        end
    end
    
    
    methods 
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
    
    methods (Access = protected)
        function T = populateStimulusTable(obj)
            % POPULATESTIMULUSTABLE
            %
            % Description:
            %   Create "stim" property table
            %
            % Overwrites from ao.core.Dataset
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

        function getStimOffsets(obj)
            % GETSTIMOFFSETS
            % ---------------------------------------------------------
            obj.stimWindows = zeros(numel(obj.epochIDs), 2);

            for i = 1:numel(obj.epochIDs)
                iStim = obj.epoch2stim(obj.epochIDs(i));
                window = [3 iStim.frames()-2];
            end
        end
    end
    
    methods
        
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
                char(obj.experimentDate), obj.extraHeader, '_ref_'];
            progressbar();
            for i = 1:numel(obj.epochIDs)
                fName = [obj.experimentDir, filesep, 'Ref', filesep, baseStr,... 
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
            %
            % ---------------------------------------------------------
            obj.ledTables = containers.Map('KeyType', 'double', 'ValueType', 'any');
            baseStr = [num2str(double(obj.source)), '_', char(obj.experimentDate), '_vis_'];

            visFiles = ls([obj.baseDirectory, filesep, 'Vis']);
            visFiles = string(deblank(visFiles));
            visFiles = visFiles(contains(visFiles, '.json'));

            progressbar();
            for i = 1:numel(obj.epochIDs)
                % fileName = [obj.experimentDir, filesep, 'Vis', filesep, baseStr,... 
                %     int2fixedwidthstr(obj.epochIDs(i), 4), '.json'];
                visStr = [obj.extraHeader, 'vis_', int2fixedwidthstr(obj.epochIDs(i), 4)];
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

    methods (Static)
        function T = readJsonLED(fileName)
            % READJSONLED
            J = loadjson(fileName);
            dataTable = J.datatable;
            lines = strsplit(dataTable, newline);


            frameNumber = []; ID = []; timestamp = []; 
            voltage1 = []; voltage2 = []; voltage3 = [];

            for i = 2:numel(lines)
                if isempty(lines{i})
                    continue
                end
                entries = strsplit(lines{i}, ', ');
                frameNumber = cat(1, frameNumber, str2double(entries{1}));
                ID = cat(1, ID, str2double(entries{2}));
                voltage1 = cat(1, voltage1, str2double(entries{4}));
                voltage2 = cat(1, voltage2, str2double(entries{5}));
                voltage3 = cat(1, voltage3, str2double(entries{6}));
                timestamp = cat(1, timestamp, str2double(entries{7}));
            end

            T = table(frameNumber, ID, voltage1, voltage2, voltage3, timestamp,...
                'VariableNames', {'Frame', 'ID', 'R', 'G', 'B', 'TimeStamp'});
            T{end, 'Frame'} = T{end-1, 'Frame'};
        end
        
        function x = getEpochTiming(T)
            x = T.TimeStamp;
            x = x - x(1);
        end
        
    end
end 