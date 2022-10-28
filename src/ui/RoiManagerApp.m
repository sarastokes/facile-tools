classdef RoiManagerApp < handle

    properties (SetAccess = private)
        dataset
        currentRoi

        uidManager
        listeners
    end

    events
        ChangedSelectedRoi
    end

    properties % (Access = private)
        figureHandle
        imHandle
        roiHandles
        idHandles
        uidHandles
        roiTable

        showCheckbox
        idCheckbox
        uidCheckbox
        roiListbox
        statusBox

        lastColor
    end

    properties (Hidden, Constant)
        ROI_HAS_UID = rgb('peach');
        ROI_NO_UID = [0 1 1];
    end

    methods
        function obj = RoiManagerApp(dataset)
            obj.dataset = dataset;

            % Initialize UID matrix, if missing
            if isempty(obj.dataset.roiUIDs)
                obj.dataset.setRoiUID();
            end

            obj.createUi();
        end
    end

    methods 
        function bind(obj)
            obj.listeners = addlistener(obj.uidManager, 'UidChanged',...
                @obj.onManager_ChangedRoi);
        end
    end

    methods
        function onManager_ChangedRoi(obj, ~, ~)
            x = obj.uidManager.lastChangedUid;
            set(obj.uidHandles(x.ID), 'String', char(x.UID));
            if isempty(char(x.UID))
                set(obj.roiHandles(x.ID), 'Color', obj.ROI_NO_UID);
                obj.lastColor = obj.ROI_NO_UID;
            else
                set(obj.roiHandles(x.ID), 'Color', obj.ROI_HAS_UID);
                obj.lastColor = obj.ROI_HAS_UID;
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

        function onChanged_RoiSelection(obj, ~, ~)
            iRoi = obj.roiListbox.Value;
            if ~isempty(obj.currentRoi) 
                set(obj.roiHandles(obj.currentRoi),...
                    'Color', obj.lastColor,...
                    'LineWidth', 0.1, 'Visible', obj.showCheckbox.Value);
            end
            obj.lastColor = get(obj.roiHandles(iRoi), 'Color');
            set(obj.roiHandles(iRoi),...
                'Color', [1 0 0], 'LineWidth', 0.3, 'Visible', 'on');
            obj.currentRoi = iRoi;
            notify(obj, 'ChangedSelectedRoi');
            set(obj.statusBox, 'String', sprintf('Selected ROI %u', obj.currentRoi));
        end

        function onChecked_ShowLabels(obj, ~, ~)
            if obj.idCheckbox.Value
                flag = true;
                if obj.uidCheckbox.Value
                    obj.uidCheckbox.Value = false;
                    obj.onChecked_ShowUIDs();
                end
            else
                flag = false;
            end
            arrayfun(@(x) set(x, 'Visible', flag), obj.idHandles);
        end

        function onChecked_ShowUIDs(obj, ~, ~)
            if obj.uidCheckbox.Value
                flag = true;
                if obj.idCheckbox.Value
                    obj.idCheckbox.Value = false;
                    obj.onChecked_ShowLabels();
                end
            else
                flag = false;
            end
            arrayfun(@(x) set(x, 'Visible', flag), obj.uidHandles);
        end

        function onEdit_RoiBox(obj, src, ~)
            try
                iRoi = str2double(src.String);
                obj.roiListbox.Value = iRoi;
                obj.onChanged_RoiSelection();
                set(src, 'String', '');
            catch
                set(src, 'ForegroundColor', 'red');
            end
        end

        function onImage_ButtonDown(obj, src, evt)
            switch class(src)
                case 'matlab.graphics.primitive.Image'
                    selectedRoi = obj.dataset.rois(...
                        round(evt.IntersectionPoint(2)), round(evt.IntersectionPoint(1)));
                case {'matlab.graphics.chart.primitive.Line', 'matlab.graphics.primitive.Text'}
                    selectedRoi = obj.tag2roi(src.Tag);
                otherwise
                    return;
            end
            if selectedRoi ~= 0
                didSet = obj.trySetListbox(obj.roiListbox, selectedRoi);
                if ~didSet
                    return;
                end
                obj.onChanged_RoiSelection();
                set(obj.statusBox, 'String', sprintf('Selected ROI %u', selectedRoi));
            else
                set(obj.statusBox, 'String', 'No ROI at location');
            end
        end

        function onOpen_UidManager(obj, ~, ~)
            if ~isempty(obj.uidManager)
                warning('UidManager already open! Close it first');
                return
            end
            obj.uidManager = UidManager(obj);

            obj.bind();
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', obj.dataset.getLabel(),...
                'DefaultUicontrolFontSize', 12);
            obj.figureHandle.Position(2) = obj.figureHandle.Position(2) - 200;
            obj.figureHandle.Position(4) = obj.figureHandle.Position(4) * 1.5;

            obj.createToolbar();

            mainLayout = uix.HBox('Parent', obj.figureHandle);
            uiLayout = uix.VBox('Parent', mainLayout, 'Padding', 3);
            obj.createUiLayout(uiLayout);

            viewLayout = uix.VBox('Parent', mainLayout);
            obj.statusBox = uicontrol(viewLayout, 'String', '');

            axLayout = axes(uipanel(viewLayout));
            hold(axLayout, 'on');
            obj.imHandle = imagesc(axLayout,... 
                imadjust(obj.dataset.avgImage),... 
                'ButtonDownFcn', @obj.onImage_ButtonDown);
            set(axLayout, 'YDir', 'reverse');
            axis(axLayout, 'equal', 'tight', 'off');
            colormap(axLayout, 'gray');

            obj.showROIs(axLayout);

            set(viewLayout, 'Heights', [25 -1]);
            set(mainLayout, 'Widths', [-1 -3]); 
        end

        function createToolbar(obj)
            mh.import = uimenu(obj.figureHandle, 'Label', 'Extras');
            uimenu(mh.import, 'Label', 'Open UID Manager',...
                'Callback', @obj.onOpen_UidManager);
        end

        function createUiLayout(obj, parentHandle)
            obj.roiListbox = uicontrol(parentHandle,...
                'Style', 'listbox',...
                'String', 1:obj.dataset.numROIs,...
                'Callback', @obj.onChanged_RoiSelection);
            ao.ui.UiUtility.horizontalBoxWithLabel(parentHandle, 'Roi',...
                'Style', 'edit', 'Callback', @obj.onEdit_RoiBox);
            obj.showCheckbox = uicontrol(parentHandle,...
                'Style', 'checkbox',...
                'String', 'Show All',...
                'Value', true,...
                'Callback', @obj.onChecked_ShowAll);
            obj.idCheckbox = uicontrol(parentHandle,...
                'Style', 'check', 'String', 'Show Labels',...
                'Value', false, 'Callback', @obj.onChecked_ShowLabels);
            obj.uidCheckbox = uicontrol(parentHandle, 'Style', 'check',...
                'String', 'Show UIDs',...
                'Callback', @obj.onChecked_ShowUIDs);

            set(parentHandle, 'Heights', [-1 25 25 25 25]);
        end

        function showROIs(obj, parentHandle)
            obj.roiTable = regionprops("table", obj.dataset.rois,... 
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
                    'FontSize', 7, 'FontName', 'Arial',...
                    'Tag', obj.roi2tag(i), 'Visible', 'off',...
                    'ButtonDownFcn', @obj.onImage_ButtonDown);
                obj.uidHandles = cat(1, obj.uidHandles, h);
            end
            obj.roiTable.ID = [1:obj.dataset.numROIs]'; %#ok<NBRAK> 
        end
    end

    methods (Static)
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