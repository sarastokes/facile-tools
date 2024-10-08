classdef MultiDatasetResponseViewer < handle


    properties
        Parent

        normFlag        (1,1)       logical = false
        colormap        (:,3)       double
        currentUID      (1,1)       {mustBeInteger} = 1;
        repeatCutoff    (1,1)       {mustBeInteger, mustBePositive} = 1;
        responseIndex               double
        uidList         (1,:)       double
    end

    properties
        figureHandle
        axisHandle
        sweeps                      matlab.graphics.primitive.Line
        avgSweep        (1,1)       matlab.graphics.primitive.Line
        uidLabel        (1,1)       matlab.ui.control.Label
        qualityLabel    (1,1)       matlab.ui.control.Label
        stimCheckBoxes              matlab.ui.control.CheckBox
        minRepeatBox
        normCheckBox    (1,1)       matlab.ui.control.CheckBox
        menuHandle
    end

    methods
        function obj = MultiDatasetResponseViewer(Dataset)
            obj.Parent = Dataset;

            obj.uidList = 1:obj.Parent.numUUIDs;
            obj.colormap = pmkmp(obj.Parent.numStimuli, 'CubicL');
            obj.createUi();
        end
    end

    methods
        function updateView(obj)
            obj.assignUidLabel();
            obj.enableValidStimuli();
            obj.assignQualityIndex();
        end

        function assignUidLabel(obj)
            obj.uidLabel.Text = sprintf('%s (N=%u)',...
                obj.Parent.uniqueUUIDs(obj.currentUID), obj.Parent.uidTable.N(obj.currentUID));
        end

        function assignQualityIndex(obj)
            obj.qualityLabel.Text = sprintf('QI = %.2f,  R = %.2f',...
                obj.Parent.uidTable.QI(obj.currentUID),...
                obj.Parent.uidTable.Corr(obj.currentUID));
        end

        function enableValidStimuli(obj)
            obj.responseIndex = [];
            resp = squeeze(obj.Parent.allResponses(obj.currentUID, :, :));
            for i = 1:obj.Parent.numStimuli
                idx = obj.Parent.getDsetRows(i);
                if isnan(resp(1,idx(1)))
                    set(obj.stimCheckBoxes(i), "Enable", "off", "Value", false);
                    obj.stimCheckBoxes(i).Enable = 'off';
                    obj.stimCheckBoxes(i).Value = false;
                    set(obj.sweeps(i), "Visible", "off");
                    obj.sweeps(i).YData = zeros(size(obj.sweeps(i).XData));
                    obj.avgSweep.YData = zeros(size(obj.avgSweep.XData));
                else
                    obj.responseIndex = [obj.responseIndex, idx];
                    set(obj.stimCheckBoxes(i), "Enable", "on", "Value", true);
                    set(obj.sweeps(i), "Visible", "on");
                    if obj.normFlag
                        obj.sweeps(i).YData = mean(roiNormPercentile(resp(:,idx)', 2), 1);
                    else
                        obj.sweeps(i).YData = squeeze(mean(resp(:, idx), 2));
                    end
                end
            end

            obj.avgSweep.Visible = "on";
            if obj.normFlag
                try
                    avgData = mean(roiNormPercentile(squeeze(...
                        obj.Parent.allResponses(obj.currentUID,:, obj.responseIndex))', 2), 1);
                catch ME
                    avgData = zeros(size(obj.avgSweep.XData));
                    if ~strcmp(ME.identifier, 'MATLAB:badsubscript') && isscalar(obj.responseIndex)
                        warning(ME.message);
                    end
                end
            else
                avgData = squeeze(mean(obj.Parent.allResponses(obj.currentUID,:,obj.responseIndex), 3, 'omitnan'));
            end
            obj.avgSweep.YData = avgData;
        end
    end

    methods (Access = private)
        function onChanged_MinRepeats(obj, src, ~)
            obj.uidList = 1:obj.Parent.numUUIDs;
            if isempty(src.Value) || src.Value < 2
                obj.repeatCutoff = 1;
            else
                obj.repeatCutoff = src.Value;
                obj.uidList = obj.uidList(obj.Parent.uidTable.N >= obj.repeatCutoff);
            end
        end

        function onChecked_Stimulus(obj, src, ~)
            idx = str2double(src.Tag);
            obj.sweeps(idx).Visible = matlab.lang.OnOffSwitchState(src.Value);
            obj.setAverageResponse();
        end

        function onChecked_Normalize(obj, src, ~)
            obj.normFlag = src.Value;
            if src.Value
                ylabel(obj.axisHandle, "Normalized dF/F");
            else
                ylabel(obj.axisHandle, "dF/F");
            end
            obj.updateView();
        end

        function onMenu_ExportFigure(obj, ~, ~)
            newAxes = exportFigure(obj.axisHandle);
            txt = sprintf('%u_%s - %s', obj.Parent.source, ...
                obj.Parent.location, obj.Parent.uniqueUUIDs(obj.currentUID));

            title(newAxes, txt, "Interpreter", "none");
            figPos(newAxes.Parent, 0.8, 0.8);
            tightfig(newAxes.Parent);
        end

        function onChanged_TargetUID(obj, src, ~)
            input = convertCharsToStrings(src.Value);
            input = upper(input);

            idx = find(obj.Parent.uniqueUUIDs == input);
            if isempty(idx)
                set(src, 'FontColor', [1 0 0]);
                return
            end

            set(src, 'FontColor', [0 0 0], "Value", "");
            obj.changeUID(idx);
        end

        function onKey_Pressed(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if ismember('shift', evt.Modifier)
                        obj.changeUID(obj.currentUID - 10);
                    else
                        obj.changeUID(obj.currentUID - 1);
                    end
                case 'rightarrow'
                    if ismember('shift', evt.Modifier)
                        obj.changeUID(obj.currentUID + 10);
                    else
                        obj.changeUID(obj.currentUID + 1);
                    end
                otherwise
                    return
            end
        end
    end

    methods (Access = private)
        function changeUID(obj, newUID)
            if newUID == obj.currentUID
                return
            end

            if newUID > obj.Parent.numUUIDs
                obj.currentUID = obj.Parent.numUUIDs;
            elseif newUID < 1
                obj.currentUID = 1;
            else
                obj.currentUID = newUID;
            end
            obj.updateView();
        end

        function setAverageResponse(obj)
            allData = [];
            for i = 1:numel(obj.sweeps)
                if obj.sweeps(i).Visible == "on"
                    allData = cat(1, allData, obj.sweeps(i).YData);
                end
            end
            if isempty(allData)
                obj.avgSweep.YData = zeros(size(obj.avgSweep.XData));
            else
                obj.avgSweep.YData = mean(allData, 1);
            end
        end
    end

    methods
        function createUi(obj)
            obj.figureHandle = uifigure(...
                "KeyPressFcn", @obj.onKey_Pressed);
            obj.figureHandle.Name = sprintf('%u %s', obj.Parent.source, obj.Parent.location);
            obj.figureHandle.Position(3) = 1.5 * obj.figureHandle.Position(3);

            obj.menuHandle = uimenu(obj.figureHandle, "Text", "Custom");
            uimenu(obj.menuHandle, "Text", "Export Figure",...
                "MenuSelectedFcn", @obj.onMenu_ExportFigure);

            mainLayout = uigridlayout(obj.figureHandle, [1 2]);
            mainLayout.ColumnWidth = {'1x', '2.5x'};

            obj.createUiPanel(mainLayout);
            obj.createAxesPanel(mainLayout);

            obj.enableValidStimuli();
        end

        function createUiPanel(obj, parent)
            mainLayout = uigridlayout(parent, [5, 1]);
            mainLayout.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit'};

            obj.uidLabel = uilabel(mainLayout, 'Text', "",...
                "HorizontalAlignment", "center",...
                "FontName", "Roboto Mono");
            obj.qualityLabel = uilabel(mainLayout, "Text", "",...
                "HorizontalAlignment", "center",...
                "FontName", "Roboto Mono", "FontSize", 10);

            ctrlLayout = uigridlayout(mainLayout, [2 2],...
                "ColumnWidth", {"fit", "1x"}, "Padding", [0 0 0 0]);
            uilabel(ctrlLayout,...
                "Text", sprintf("Repeat Cutoff (1-%u)", obj.Parent.numReps));
            obj.minRepeatBox = uieditfield(ctrlLayout, 'numeric',...
                'Value', 1, 'Limits', [1, obj.Parent.numReps],...
                'Tooltip', 'Minimum number of repeats',...
                'ValueChangedFcn', @obj.onChanged_MinRepeats);
            obj.normCheckBox = uicheckbox(ctrlLayout,...
                "Text", "Normalize",...
                "Value", false, "ValueChangedFcn", @obj.onChecked_Normalize);
            obj.normCheckBox.Layout.Column = [1 2];

            dsetLayout = uigridlayout(mainLayout, [obj.Parent.numStimuli 1],...
                "RowSpacing", 0, "Padding", [5 0 0 0],...
                "BackgroundColor", [0.99 0.99 0.99]);
            for i = 1:obj.Parent.numStimuli
                %boxName = "2" + extractAfter(obj.Parent.StimTable.Dataset(i), obj.Parent.location + "_2") + "_" + obj.Parent.StimTable.Stimulus(i);
                boxName = "2" + extractAfter(obj.Parent.StimTable.DsetName(i), obj.Parent.location + "_2") + "_" + obj.Parent.StimTable.Stimulus(i);
                obj.stimCheckBoxes = cat(1, obj.stimCheckBoxes,...
                    uicheckbox(dsetLayout, "Text", boxName,...
                        "FontSize", 8, "FontColor", obj.colormap(i,:),...
                        "Tag", num2str(i), "Enable", "off",...
                        "ValueChangedFcn", @obj.onChecked_Stimulus));
            end

            navLayout = uigridlayout(mainLayout, [1 2]);
            uilabel(navLayout, "Text", "Go to UID");
            uieditfield(navLayout,...
                "ValueChangedFcn", @obj.onChanged_TargetUID);

        end

        function createAxesPanel(obj, parent)
            obj.axisHandle = uiaxes(parent);
            hold(obj.axisHandle, 'on');
            xlim(obj.axisHandle, [0, max(obj.Parent.xpts)]);
            xlabel(obj.axisHandle, 'Time (s)');
            ylabel(obj.axisHandle, 'Normalized dF/F');

            if ~isempty(obj.Parent.ups)
                xregion(obj.axisHandle, obj.Parent.ups, obj.Parent.INC_PROPS{:});
            end

            if ~isempty(obj.Parent.downs)
                xregion(obj.axisHandle, obj.Parent.downs, obj.Parent.DEC_PROPS{:});
            end

            zeroBar(obj.axisHandle, "y");

            for i = 1:obj.Parent.numStimuli
                boxName = "2" + extractAfter(obj.Parent.StimTable.DsetName(i), obj.Parent.location + "_2") + "_" + obj.Parent.StimTable.Stimulus(i);
                obj.sweeps = cat(1, obj.sweeps,...
                    line(obj.axisHandle, obj.Parent.xpts, zeros(size(obj.Parent.xpts)),...
                        'Color', obj.colormap(i,:), 'LineWidth', 0.5,...
                        'Tag', num2str(i), 'DisplayName', boxName, 'Visible', 'off'));
            end
            obj.avgSweep = line(obj.axisHandle, obj.Parent.xpts, zeros(size(obj.Parent.xpts)),...
                'Color', [0.3 0.3 0.3], 'LineWidth', 2, 'Visible', 'off');
        end
    end
end