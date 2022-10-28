classdef DatasetLED < ao.core.Dataset
    
    properties
        ledTable
    end
    
    methods
        function obj = DatasetLED(expDate, source, epochIDs, baseDir, videoNames, varargin)
            obj@ao.core.Dataset(expDate, source, epochIDs, NaN, baseDir,... 
                'LEDVideoNames', videoNames, varargin{:});
            obj.ledVideoNames = videoNames;
            obj.ledTable = containers.Map();
        end
    end
    
    methods
        function getRegisteredVideoNames(obj, ~, ~)
            obj.registeredVideos = repmat("", size(obj.epochIDs));
            for i = 1:numel(obj.epochIDs)
                fileName = ['vis#', int2fixedwidthstr(obj.epochIDs(i), 3), '.tif'];
                obj.registeredVideos(i) = [obj.baseDirectory,... 
                    'Analysis', filesep, 'Videos', filesep, fileName];
            end
        end
    end
    
    methods (Access = protected)
        function y = getShortName(obj, epochID) %#ok<INUSL>
            % GETSHORTNAME
            %
            % Description:
            %   Naming convention used for saving snapshots and .tif files
            % -------------------------------------------------------------
            y = ['vis#', int2fixedwidthstr(epochID, 3)];
        end
        
        function filePath = getAttributesFilename(obj, epochID)
            % GETATTRIBUTESFILENAME
            %
            % Description:
            %   Get the name of the file with epoch attributes
            % -------------------------------------------------------------
            iName = obj.ledVideoNames(num2str(epochID));
            iName = char(iName(1));
            header = '_ch2_fs';
            ind = strfind(iName, header);
            filePath = [iName(1:ind-1), iName(ind+numel(header):ind+numel(header)+7), '.txt'];
            filePath = strrep(filePath, 'Vis', 'Ref');
            filePath = strrep(filePath, 'vis', 'ref');
            % filePath = [obj.baseDirectory, filesep, 'Ref', filesep, fileName];
        end
    end
    
    methods
        function getLEDTraces(obj)
            % GETLEDTRACES
            % -------------------------------------------------------------
            
            for i = 1:numel(obj.epochIDs)
                videoNames = obj.ledVideoNames(num2str(obj.epochIDs));
                T = [];
                for j = 1:numel(videoNames)
                    T = [T; obj.readJsonLED(fileName)];
                end
                obj.ledTables(num2str(obj.epochIDs)) = T;
            end
        end
        
    end
    
    methods (Static)
        function T = readJsonLED(fileName)
            J = loadjson(fileName);
            dataTable = J.datatable;
            lines = strsplit(dataTable, newline);


            frameNumber = []; ID = []; voltage1 = []; voltage2 = []; voltage3 = [];
            timestamp = []; 

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
    end
end