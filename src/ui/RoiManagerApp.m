classdef RoiManagerApp < handle   
    % Info flow: imageclick/editbox -> table selection -> roihandles
    
    properties
        dataset
        datasetName                     char
        dsetImage      
        flipFlag
        rois                            double              
        roiTable

        Figure
        Layout                          matlab.ui.container.GridLayout
        Table                           matlab.ui.control.Table
        Image                           matlab.graphics.primitive.Image
        Axes                            matlab.ui.control.UIAxes
        Tag             (1,:)           char

        idHandles
        roiHandles
        uidHandles
        
        showCheckbox                    matlab.ui.control.CheckBox
        idCheckbox                      matlab.ui.control.CheckBox
        uidCheckbox                     matlab.ui.control.CheckBox
        statusBox                       matlab.ui.control.Label
        roiCountBox                     matlab.ui.control.Label
        exportButton                    matlab.ui.control.Button

        lastColor(1,3)                  double
        currentRoi(1,1)                 double                      = 1

        listeners                       event.listener
    end

    events 
        SelectedRoi
    end

    properties (Hidden, Constant)
        ROI_HAS_UID = rgb('peach');
        ROI_NO_UID = [0 1 1];
    end

    methods
        function obj = RoiManagerApp(dataset, parentHandle, flipFlag)
            if isa(dataset, 'ao.core.Dataset')
                obj.datasetName = dataset.getLabel();
                obj.dsetImage = dataset.avgImage;
                obj.rois = dataset.rois;
            elseif isa(dataset, 'ao.core.SpectralData')
                obj.datasetName = [dataset.eyeName, upper(dataset.imagingSide(1)), '_', char(dataset.experimentDate)];
                obj.dsetImage = dataset.avgImage;
                obj.rois = dataset.rois;
            elseif isa(dataset, 'SimpleDataset')
                obj.datasetName = dataset.exptName;
                obj.dsetImage = dataset.avgImage();
                obj.rois = dataset.rois;
            elseif isa(dataset, 'aod.builtin.annotations.Rois')
                if ~isempty(dataset.Parent)
                    obj.datasetName = dataset.Parent.getGroupName();
                else
                    obj.datasetName = dataset.Name;
                end
                obj.dsetImage = dataset.Image;
                obj.rois = dataset.Data;
            end
            obj.dataset = dataset;


            if nargin < 3
                obj.flipFlag = false;
            else
                obj.flipFlag = flipFlag;
            end
            if obj.flipFlag
                obj.dsetImage = flipud(obj.dsetImage);
                obj.rois = flipud(obj.rois);
            end

            if nargin >= 2
                obj.Figure = parentHandle;
            end

            obj.createUi();
        end

        function setTag(obj, str)
            obj.Tag = str;
            obj.exportButton.Tag = str;
        end

        function setListener(obj, eventObj, eventName)
            obj.listeners = addlistener(eventObj, eventName, obj.updateRoiCounts());
        end
    end

    methods (Access = private)
        function onPush_Export(obj, ~, ~)
            if isa(obj.dataset, 'aod.core.Annotation')
                assignin('base', 'roiUIDs', obj.Table.Data);
                disp('Saved to workspace as "roiUIDs"');
            else
                obj.dataset.setRoiUIDs(obj.Table.Data);
                disp('Updated roiUIDs - remember to save dataset');
            end
        end

        function onEdited_Cell(obj, src, evt)
            if evt.NewData == ""
                return;
            end

            if strlength(evt.NewData) ~= 3 || ~all(isletter(evt.NewData))
                warndlg('Invalid UID, must be 3 letter string');
                src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
                return;
            elseif nnz(strcmp(evt.NewData, src.Data.UID)) > 1
                warndlg('Invalid UID, already present in dataset');
                src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
                return;
            else  % New UID is valid
                roiID = src.Data{evt.Indices(1), 1};
                changedUid = src.Data{evt.Indices(1), 2};

                set(obj.uidHandles(roiID), 'String', char(changedUid));
                if isempty(char(changedUid))
                    set(obj.roiHandles(roiID), 'Color', obj.ROI_NO_UID);
                    obj.lastColor = obj.ROI_NO_UID;
                else
                    set(obj.roiHandles(roiID), 'Color', obj.ROI_HAS_UID);
                    obj.lastColor = obj.ROI_HAS_UID;
                end
                % TODO: Update UID text
                obj.updateRoiCounts();
            end
        end

        function onSelected_TableCell(obj, ~, ~)
            obj.onChanged_RoiSelection();
        end

        function onChanged_RoiSelection(obj, ~, ~)
            % Always get ROI, even if UID was selected
            iRoi = obj.Table.DisplayData{obj.Table.Selection(1), 1};
            if ~isempty(obj.currentRoi) 
                set(obj.roiHandles(obj.currentRoi),...
                    'Color', obj.lastColor,...
                    'LineWidth', 0.1, 'Visible', obj.showCheckbox.Value);
            end
            obj.lastColor = get(obj.roiHandles(iRoi), 'Color');
            set(obj.roiHandles(iRoi),...
                'Color', [1 0 0], 'LineWidth', 0.3, 'Visible', 'on');
            obj.currentRoi = iRoi;
            set(obj.statusBox, 'Text', sprintf('Selected ROI %u', obj.currentRoi));
            notify(obj, 'SelectedRoi');
        end

        function onImage_ButtonDown(obj, src, evt)
            switch class(src)
                case 'matlab.graphics.primitive.Image'
                    selectedRoi = obj.rois(...
                        round(evt.IntersectionPoint(2)), round(evt.IntersectionPoint(1)));
                case {'matlab.graphics.chart.primitive.Line', 'matlab.graphics.primitive.Text'}
                    selectedRoi = obj.tag2roi(src.Tag);
                otherwise
                    return;
            end
            if selectedRoi ~= 0
                didSet = obj.trySelectTableCell(obj.Table, selectedRoi);
                if ~didSet
                    return;
                end
                obj.onChanged_RoiSelection();
                set(obj.statusBox, 'Text', sprintf('Selected ROI %u', selectedRoi));
            else
                set(obj.statusBox, 'Text', 'No ROI at location');
            end
        end

        function onEdited_RoiBox(obj, src, ~)
            try 
                if obj.isUID(src.Value)
                    if ismember(upper(src.Value), obj.Table.DisplayData{:,2})
                        iRoi = find(obj.Table.DisplayData{:,2} == upper(src.Value));
                    else
                        obj.statusBox.Text = 'Uid not found!';
                        return
                    end
                else
                    iRoi = str2double(src.Value);
                    if iRoi > height(obj.Table) || iRoi < 1
                        obj.statusBox.Text = 'Roi not found!';
                        return
                    end
                end
                scroll(obj.Table, 'row', iRoi);
                obj.Table.Selection = [iRoi, 2]; % Select UID always
                obj.statusBox.Text = sprintf('Selected ROI %u', iRoi);
                obj.onChanged_RoiSelection();
                set(src, 'FontColor', [0 0 0]);
                set(src, 'Value', '');

            catch
                set(src, 'FontColor', 'red');
            end
        end

        function onChecked_ShowAll(obj, src, ~)
            if src.Value
                flag = "on";
            else
                flag = "off";
            end

            for i = 1:numel(obj.roiHandles)
                obj.roiHandles(i).Visible = flag;
            end
        end

        function onChecked_ShowRoiLabels(obj, ~, ~)
            if obj.idCheckbox.Value
                flag = true;
                if obj.uidCheckbox.Value
                    obj.uidCheckbox.Value = false;
                    obj.onChecked_ShowUids();
                end
            else
                flag = false;
            end
            arrayfun(@(x) set(x, 'Visible', flag), obj.idHandles);
        end

        function onChecked_ShowUids(obj, ~, ~)
            if obj.uidCheckbox.Value
                flag = true;
                if obj.idCheckbox.Value
                    obj.idCheckbox.Value = false;
                    obj.onChecked_ShowRoiLabels();
                end
            else
                flag = false;
            end
            arrayfun(@(x) set(x, 'Visible', flag), obj.uidHandles);
        end
    end

    methods 
        function updateRoiCounts(obj)
            obj.roiCountBox.Text = sprintf('%u of %u',... 
                nnz(obj.Table.Data.UID ~= ""), height(obj.Table.Data));
        end

        function updateRoiCircles(obj, roiID, changedUid)
            set(obj.uidHandles(roiID), 'String', char(changedUid));
            if isempty(char(changedUid))
                set(obj.roiHandles(roiID), 'Color', obj.ROI_NO_UID);
                obj.lastColor = obj.ROI_NO_UID;
            else
                set(obj.roiHandles(roiID), 'Color', obj.ROI_HAS_UID);
                obj.lastColor = obj.ROI_HAS_UID;
            end
            % TODO: Update UID text
        end
    end

    methods (Access = private)

        function createUi(obj)
            if isempty(obj.Figure)
                obj.Figure = uifigure(...
                    'Name', obj.datasetName,...
                    'DefaultUicontrolFontSize', 12,...
                    'DefaultUicontrolFontName', get(0, 'defaultUicontrolFontName'));
                obj.Figure.Position(3) = obj.Figure.Position(3)+50;
                obj.Figure.Position(4) = obj.Figure.Position(4)+100;
                movegui(obj.Figure, 'center');
                obj.Layout = uigridlayout(obj.Figure, [1 3]);
            else
                obj.Layout = uigridlayout(obj.Figure, [1 3]);
            end

            plotGrid = uigridlayout(obj.Layout, [2 1]);
            uiGrid = uigridlayout(obj.Layout, [7 1]);

            obj.Table = uitable(uiGrid);
            obj.Table.Data = obj.dataset.roiUIDs;
            obj.Table.ColumnEditable = [false true];
            obj.Table.ColumnWidth = {30, 45};
            obj.Table.CellEditCallback = @obj.onEdited_Cell;
            obj.Table.SelectionChangedFcn = @obj.onSelected_TableCell;
            obj.Table.Layout.Row = 1; 
            obj.Table.Layout.Column = 1;

            obj.roiCountBox = uilabel(uiGrid, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.roiCountBox.Layout.Row = 2;
            obj.roiCountBox.Layout.Column = 1;

            roiEditGrid = uigridlayout(uiGrid, [1 2]);
            roiEditGrid.Layout.Row = 3; 
            roiEditGrid.Layout.Column = 1;

            lbl = uilabel(roiEditGrid, 'Text', 'ROI:',...
                'HorizontalAlignment', 'center');
            lbl.Layout.Row = 1; 
            lbl.Layout.Column = 1;
            edf = uieditfield(roiEditGrid,...
                'ValueChangedFcn', @obj.onEdited_RoiBox);
            edf.Layout.Row = 1;
            edf.Layout.Column = 2;
            roiEditGrid.ColumnWidth = {25, '1x'};

            obj.showCheckbox = uicheckbox(uiGrid,...
                'Text', 'Show All',...
                'Value', 1,...
                'ValueChangedFcn', @obj.onChecked_ShowAll);
            obj.showCheckbox.Layout.Row = 4; 
            obj.showCheckbox.Layout.Column = 1;

            obj.idCheckbox = uicheckbox(uiGrid,...
                'Text', 'Show labels',...
                'ValueChangedFcn', @obj.onChecked_ShowRoiLabels);
            obj.idCheckbox.Layout.Row = 5; 
            obj.idCheckbox.Layout.Column = 1;

            obj.uidCheckbox = uicheckbox(uiGrid,...
                'Text', 'Show UIDs',...
                'ValueChangedFcn', @obj.onChecked_ShowUids);
            obj.uidCheckbox.Layout.Row = 6; 
            obj.uidCheckbox.Layout.Column = 1;

            obj.exportButton = uibutton(uiGrid,...
                'Text', 'Export', ...
                'ButtonPushedFcn', @obj.onPush_Export);
            obj.exportButton.Layout.Row = 7; 
            obj.exportButton.Layout.Column = 1;

            % Plot grid
            obj.statusBox = uilabel(plotGrid, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.statusBox.Layout.Row = 1;
            obj.statusBox.Layout.Column = 1;

            obj.Axes = uiaxes(plotGrid, 'YDir', 'reverse');
            obj.Axes.Toolbar.Visible = 'off';
            hold(obj.Axes, 'on');
            obj.Image = imagesc(obj.Axes,... 
                imadjust(obj.dsetImage),... 
                'ButtonDownFcn', @obj.onImage_ButtonDown);
            axis(obj.Axes, 'equal', 'tight', 'off');
            colormap(obj.Axes, 'gray');
            obj.Axes.Layout.Row = 2;
            obj.Axes.Layout.Column = 1;

            obj.buildRoiViews(obj.Axes);

            obj.Layout.ColumnWidth = {'2.6x', '1x'}; 
            uiGrid.RowHeight = {'1x', 20, 'fit', 20, 20, 20, 20};
            plotGrid.RowHeight = {20, '1x'};

            obj.updateRoiCounts();
        end

        function buildRoiViews(obj, parentHandle)
             obj.roiTable = regionprops("table", obj.rois,... 
                "Centroid", "EquivDiameter", "Extrema");
            obj.roiHandles = [];
            for i = 1:height(obj.roiTable)
                if isempty(char(obj.dataset.roiUIDs.UID(i)))
                    co = obj.ROI_NO_UID;
                else
                    co = obj.ROI_HAS_UID;
                end
                h = obj.plotCircle(obj.roiTable.Centroid(i,:),... 
                    obj.roiTable.EquivDiameter(i)/2,...
                    'LineWidth', 0.2, 'Color', co,...
                    'Parent', parentHandle,  'Tag', obj.roi2tag(i),... 
                    'ButtonDownFcn', @obj.onImage_ButtonDown);
                obj.roiHandles = cat(1, obj.roiHandles, h);

                xy = obj.roiTable.Extrema{i};
                h = text(xy(1,1), xy(1,2), sprintf('%d', i),...
                    'Parent', parentHandle,...
                    'Clipping', 'on', 'Color', [1 1 0],...
                    'FontSize', 8, 'FontName', 'Arial',...
                    'Tag', obj.roi2tag(i), 'Visible', 'off',...
                    'ButtonDownFcn', @obj.onImage_ButtonDown);
                obj.idHandles = cat(1, obj.idHandles, h);

                h = text(xy(1,1), xy(1,2), char(obj.dataset.roiUIDs.UID(i)),...
                    'Parent', parentHandle, ...
                    'Clipping', 'on', 'Color', [1 1 0], ...
                    'FontSize', 10, 'FontName', 'Arial',...
                    'Tag', obj.roi2tag(i), 'Visible', 'off',...
                    'ButtonDownFcn', @obj.onImage_ButtonDown);
                obj.uidHandles = cat(1, obj.uidHandles, h);
            end
            obj.roiTable.ID = [1:obj.dataset.numROIs]'; %#ok<NBRAK> 
        end
    end

    methods (Static)
        function tf = isUID(txt)
            if isstring(txt)
                txt = char(txt);
            end
            if ~ischar(txt)
                tf = false;
                return
            else
                txt = char(txt);
            end

            if numel(txt) ~= 3
                tf = false;
                return
            else
                tf = true;
            end

            if nnz(isletter(txt)) < 3
                tf = false;
                return
            else
                tf = true;
            end
        end

        function tag = roi2tag(roi)
            tag = ['roi', num2str(roi)];
        end

        function roi = tag2roi(tag)
            roi = str2double(tag(4:end));
        end

        function h = plotCircle(xy, r, varargin)
            th = 0:pi/50:2*pi;
            h = plot(r * cos(th) + xy(1), r * sin(th) + xy(2), varargin{:});
        end

        function tf = trySelectTableCell(T, value)
            try
                newRow = find(T.DisplayData.ID == value);
                scroll(T, 'row', newRow);
                T.Selection = [newRow, 2];
                tf = true;
            catch
                tf = false;
            end
        end

        function tf = trySetListbox(lBox, value)
            try
                lBox.Value = value;
                tf = true;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:hg:uicontrol:ValueMustBeWithinStringRange')
                    lBox.Value = [];
                    warning('Value not within listbox range')
                else
                    rethrow(ME);
                end
                tf = false;
            end
        end
    end
end