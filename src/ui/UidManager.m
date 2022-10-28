classdef UidManager < handle

    properties
        lastChangedUid

        parentHandle
        figureHandle
        Table

        uidText
    end

    events 
        UidChanged
    end

    properties (Access = private)
        hasUidChanged = false;
    end

    methods
        function obj = UidManager(parentHandle)
            obj.parentHandle = parentHandle;
            if isempty(obj.parentHandle.dataset.roiUIDs)
                obj.parentHandle.dataset.setRoiUID();
            end
            
            obj.bind();
            
            obj.createUi();
        end

    end

    methods (Access = private)
        function updateUidText(obj)
            obj.uidText.Value = sprintf('%u of %u',... 
                nnz(obj.Table.Data.UID == ""), height(obj.Table.Data));
        end
    end

    methods (Access = private)
        function onAppChangedSelectedRoi(obj, ~, ~)
            newRow = find(obj.Table.DisplayData.ID == obj.parentHandle.currentRoi);
            scroll(obj.Table, 'row', newRow);
            obj.Table.Selection = [newRow, 2];
        end

        function onEditCell(obj, src, evt)
            if evt.NewData == ""
                return;
            end

            if strlength(evt.NewData) ~= 3 || ~all(isletter(evt.NewData))
                warning('Invalid UID, must be 3 letter string');
                src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
                return;
            elseif nnz(strcmp(evt.NewData, src.Data.UID)) > 1
                warning('Invalid UID, already present in dataset');
                src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
                return;
            else  % New UID is valid
                obj.lastChangedUid = src.Data(evt.Indices(1), :);
                obj.updateUidText();
                obj.hasUidChanged = true;
                notify(obj, 'UidChanged');
            end
        end

        function onPush_Export(obj, ~, ~)
            assignin('base', 'roiUIDs', obj.Table.Data);
            disp('Assigned table to roiUIDs');
        end
    end

    methods (Access = private)
        function bind(obj)
            addlistener(obj.parentHandle, 'ChangedSelectedRoi',...
                @(src, evt)obj.onAppChangedSelectedRoi);
        end

        function createUi(obj)
            
            obj.figureHandle = uifigure(...
                'Name', obj.parentHandle.dataset.getLabel(),...
                'Position', [0 0 250 410],...
                'DefaultUicontrolFontSize', 12);
            movegui(obj.figureHandle, 'center');
            drawnow;

            obj.Table = uitable(obj.figureHandle,...
                'Position', [5 30 240 375]);
            obj.Table.Data = obj.parentHandle.dataset.roiUIDs;
            obj.Table.ColumnEditable = [false true];
            obj.Table.CellEditCallback = @obj.onEditCell;
            uibutton(obj.figureHandle, ...
                'Position', [5 5 50 20],...
                'Text', 'Export',...
                'ButtonPushedFcn', @obj.onPush_Export);
            obj.uidText = uitextarea(obj.figureHandle,...
                'Position', [60 5 150 20], 'Editable', 'off');
        end
    end

end

