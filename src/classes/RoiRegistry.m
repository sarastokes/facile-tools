classdef RoiRegistry < handle

    properties 
        tforms
    end

    properties (SetAccess = private)
        label 
        names 
        roiMaps
        roiCounts
        avgImages
        roiTable 
        uidTable 
        typeTable
        uidProps
    end

    properties (Dependent)
        numDatasets
        numUIDs
        numROIs
    end

    methods
        function obj = RoiRegistry(label)
            obj.label = label;
            obj.names = [];
            obj.uidProps = containers.Map();
        end

        function value = get.numDatasets(obj)
            value = numel(obj.names);
        end

        function value = get.numUIDs(obj)
            value = size(obj.uidTable, 1);
        end

        function value = get.numROIs(obj)
            value = height(obj.roiTable);
        end

        function row = getRowByRoi(obj, expName, roi)
            % GETROWBYROI
            col = obj.uidTable.(expName);
            row = obj.uidTable(col == roi, :);
        end

        function row = getRowByUid(obj, uid)
            % GETROWBYUID
            row = obj.uidTable(obj.uidTable.UID == uid, :);
        end

        function uid = getRoiUid(obj, roiID, dsetID)
            % GETROIUID
            uid = obj.roiTable{obj.roiTable.ID == roiID & obj.roiTable.ExperimentID == dsetID, 'UID'};
        end

        function roiID = getUidRoi(obj, uid, dsetID)
            % GETUIDROI
            roiID = obj.uidTable{obj.uidTable.UID == uid, dsetID+1};
        end

        function add(obj, varargin)
            % ADDDATASETS
            for i = 1:(nargin-1)
                dset = varargin{i};
                if ~isempty(obj.names) && ismember(string(dset.experimentDate), obj.names)
                    error('Dataset already exists!');
                end
                if nnz(dset.roiUIDs.UID == "") > 1
                    error('Dataset %s has missing UIDs!', char(dset.experimentDate));
                end
                obj.addDataset(dset);
            end
        end

        function removeDatasets(obj, dsetName)
            % REMOVEDATASETS
            obj.remove(dsetName);
        end
    end

    methods 
        function calcRoiOffsets(obj)
            S = regionprops(squeeze(obj.roiMaps(:,:,1)), 'Centroid');
            baseXY = cat(1, S.Centroid);

            for j = 1:size(baseXY,1)
                S = regionprops(squeeze(obj.roiMaps(:,:,2)), 'Centroid');
                newXY = cat(1, S.Centroid);
                uid = obj.getRoiUid(j, 2);
            end
        end

        function [N, h] = quickStats(obj)
            % QUICKSTATS
            N = zeros(height(obj.uidTable), 1);
            for i = 1:height(obj.uidTable)
                N(i) = nnz(obj.uidTable{i, 2:end});
            end

            figure(); hold on;
            h = histogram(N);
            title('Sessions Per UID');
            ylabel('# of imaging sessions');
            xlabel('# of UIDs');
            set(gca, 'XTick', 1:obj.numDatasets);
        end

        function populateUidProps(obj)
            if isempty(obj.uidProps)
                obj.uidProps = containers.Map();
            end
            for i = height(obj.uidTable.UID)
                if ~obj.uidProps.isKey(obj.uidTable.UID(i))
                    obj.uidProps(obj.uidTable.UID(i)) = "";
                end
            end
        end
       
        function populateTypeTable(obj)
            % POPULATETYPETABLE
            obj.typeTable = table(obj.uidTable.UID,...
                zeros(size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                repmat("", size(obj.uidTable.UID)),...
                'VariableNames', {'UID', 'N', 'Type', 'Info', 'Polarity', 'Kinetics', 'Color', 'RF', 'S', 'Notes'});
            for i = 1:size(obj.uidTable,1)
                obj.typeTable.N(i) = nnz(obj.uidTable{i, 2:end});
            end
        end

        function setTypeTable(obj, newTypeTable)
            assert(isequal(size(obj.typeTable), size(newTypeTable)),...
                'New type table must have the same size as existing table');
            obj.typeTable = newTypeTable;
        end

        function integrateTypeTable(obj, newTypeTable)
            for i = 1:height(newTypeTable)
                idx = find(obj.typeTable.UID == newTypeTable.UID(i));
                if isempty(idx)
                    warning('UID %s not found, skipping', newTypeTable.UID(i));
                else
                    obj.typeTable(idx, 3:end) = newTypeTable(i, 3:end);
                end
            end
        end
    end

    methods (Access = private)
        function addDataset(obj, dset)
            T = dset.roiUIDs;
            T.Experiment = repmat(string(dset.experimentDate), [height(T), 1]);
            T.ExperimentID = repmat(numel(obj.names)+1, [height(T), 1]);

            obj.roiCounts = cat(2, obj.roiCounts, dset.numROIs);
            % TODO: Hard coding this could be an issue in the future
            if size(dset.avgImage, 2) > 242
                iImage = dset.avgImage(:,end-241:end);
            else
                iImage = dset.avgImage;
            end
            if size(dset.rois, 2) > 242
                iRois = dset.rois(:,end-241:end);
            else
                iRois = dset.rois;
            end

            obj.avgImages = cat(3, obj.avgImages, iImage);
            obj.roiMaps = cat(3, obj.roiMaps, iRois);

            obj.roiTable = [obj.roiTable; T];
            obj.names = cat(1, obj.names, string(dset.experimentDate));

            % Identify new UIDs
            if ~isempty(obj.uidTable)
                newUIDs = dset.roiUIDs.UID(~ismember(dset.roiUIDs.UID, obj.uidTable.UID));
            else
                newUIDs = dset.roiUIDs.UID;
            end
            
            % Update uidTable
            obj.createUidTable();

            % Add new UIDs to uidProps
            obj.populateUidProps();
        end

        function remove(obj, dsetName)
            % REMOVE
            idx = find(obj.names == string(dset.experimentDate));
            newNames = obj.names;
            newNames{idx} = []; %#ok<FNDSB> 
            T = obj.roiTable;
            T(T.Experiment == dsetName, :) = [];

            obj.roiMaps(dsetName) = [];  % TODO
            obj.uidTable.(dsetName) = [];
            obj.names = newNames;
            obj.roiTable = T;
        end

        function createUidTable(obj)
            % CREATEUIDTABLE
            uUIDs = unique(obj.roiTable.UID);

            T = table(uUIDs, 'VariableNames', {'UID'});
            for i = 1:numel(obj.names)
                dset = obj.roiTable(obj.roiTable.Experiment == obj.names{i}, :);
                T.(obj.names{i}) = zeros(height(T), 1);
                for j = 1:numel(uUIDs)
                    idx = find(dset.UID == uUIDs(j));
                    if ~isempty(idx)
                        T{j, obj.names{i}} = dset.ID(idx);
                    end
                end
            end
            obj.uidTable = T;
            obj.uidTable = sortrows(obj.uidTable, 'UID');
        end
    end
end 