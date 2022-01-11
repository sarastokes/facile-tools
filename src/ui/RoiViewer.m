classdef RoiViewer < handle

    properties (SetAccess = private)
        numROIs
        epochIDs
        signals
        signalsZ
        stim
        xpts
        QI
        
        hpCut
        lpCut
        includedEpochs
        stimWindow
        bkgdWindow
        
        autoX

        currentRoi
        stimPatch
        titleStr
        signalAxis
        figureHandle
    end

    properties (Hidden, Dependent = true)
        shadeError
    end

    properties (Hidden, Constant)
        FRAME_RATE = 25;
    end

    methods 
        function obj = RoiViewer(rawData, bkgdWindow, stimWindow, stim)

            obj.xpts = getX(size(rawData, 2), obj.FRAME_RATE);
            obj.numROIs = size(rawData, 1);

            obj.stimWindow = (1/obj.FRAME_RATE) * stimWindow;
            obj.bkgdWindow = bkgdWindow;

            if ndims(rawData) == 2 %#ok
                obj.signals = getDFF(rawData, obj.bkgdWindow, false);
                obj.signalsZ = roiZScores(rawData, obj.bkgdWindow);
                signalsSmoothed = mysmooth2(obj.signals, 100);
                obj.epochIDs = 1;
            else
                obj.signals = zeros(size(rawData));
                obj.signalsZ = zeros(size(rawData));
                for i = 1:size(rawData, 3)
                    obj.signals(:,:,i) = getDFF(rawData(:,:,i), obj.bkgdWindow, false);
                    obj.signalsZ(:,:,i) = roiZScores(rawData(:,:,i), obj.bkgdWindow);
                end
                signalsSmoothed = mysmooth32(obj.signals, 100);
                obj.epochIDs = 1:size(rawData, 3);
            end
            
            if nargin == 4
                obj.stim = stim;
            end
            
            % Get the quality index from smoothed signals
            obj.QI = qualityIndex(signalsSmoothed);

            obj.includedEpochs = true(1, numel(obj.epochIDs));
            obj.currentRoi = 1;
            obj.autoX = true;
            
            assignin('base', 'app', obj);
            obj.createUi();
        end
        
        function setTitle(obj, str)
            set(obj.figureHandle, 'Name', str);
        end
    end

    methods  % Dependent set/get methods
        function shadeError = get.shadeError(obj)
            h = findobj(obj.figureHandle, 'Tag', 'ShadedError');
            shadeError = h.Value;
        end
    end

    methods (Access = private)

        function changeRoi(obj, varargin)
            obj.updateSignalPlot();

            set(findByTag(obj.figureHandle, 'CurrentRoi'), ...
                'String', sprintf('ROI = %u / %u', obj.currentRoi, obj.numROIs));
            if obj.QI(obj.currentRoi) < 0.5
                txtColor = [0.8, 0, 0];
            else
                txtColor = [0, 0, 0];
            end
            set(findByTag(obj.figureHandle, 'QI'),...
                'String', sprintf('QI = %.2f', obj.QI(obj.currentRoi)),...
                'ForegroundColor', txtColor);
            
        end

        function updateSignalPlot(obj)
            
            if nnz(obj.includedEpochs) == 0
                return
            end
            
            X = obj.xpts;
            
            % Get DFF or ZScore
            if get(findobj(obj.figureHandle, 'Tag', 'ZScore'), 'Value')
                allSignals = obj.signalsZ;
                ylabel(obj.signalAxis, 'Response (SD)');
            else
                allSignals = obj.signals;
                ylabel(obj.signalAxis, 'Response (dF/F)');
            end 
            
            % Fill NaNs (warning appeared earlier on them)
            if nnz(isnan(allSignals)) > 0
                allSignals = fillmissing(allSignals, 'previous', 1);
            end

            % Get only the traces currently checked
            allSignals = squeeze(allSignals(obj.currentRoi, :, obj.includedEpochs));
            if nnz(obj.includedEpochs) == 1
                allSignals = allSignals';
            end
            
            % High pass filter if needed
            if ~isempty(obj.hpCut) && obj.hpCut ~= 0
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = highPassFilter(...
                        allSignals(:, i), obj.hpCut, obj.xpts(2)-obj.xpts(1));
                end
            end
            
            % Low pass filter if needed
            if ~isempty(obj.lpCut) && obj.lpCut ~= 0
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = lowPassFilter(...
                        allSignals(:, i), obj.lpCut, obj.xpts(2)-obj.xpts(1));
                end
            end

            % Smooth each signal if needed
            h = findobj(obj.figureHandle, 'Tag', 'Smooth');
            if ~isempty(h.String) && ~strcmp(h.String, '1')
                smoothFac = str2double(h.String);
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = mysmooth(allSignals(:, i), smoothFac);
                end
            end
            
            % Derivative if needed
            if get(findByTag(obj.figureHandle, 'dfdt'), 'Value')
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = gradient(allSignals(:, i));
                end
            end
            
            % Plot the individual signals, if necessary
            delete(findall(obj.signalAxis, 'Tag', 'SignalLine'));
            if ~obj.shadeError
                if numel(obj.epochIDs) > 1
                    co = pmkmp(numel(obj.epochIDs), 'CubicL');
                    co = co(obj.includedEpochs, :);
                else
                    co = [0, 0, 0.3];
                end
                % TODO: fix later
                if numel(X) < size(allSignals, 1)
                    X = [0 X];
                end
                for i = 1:size(allSignals, 2)
                    plot(obj.signalAxis, X, allSignals(:, i),...
                        'Color', co(i,:), 'LineWidth', 0.55,... 
                        'Tag', 'SignalLine');
                end
            end

            % Calc and plot the average/median
            if nnz(obj.includedEpochs) > 1
                avgSignal = nanmean(allSignals, 2);
                if obj.shadeError
                    h = shadedErrorBar(X, avgSignal,... 
                        std(allSignals, [], 2));
                    h.mainLine.Tag = 'SignalLine';
                    h.patch.Tag = 'SignalLine';
                    arrayfun(@(X) set(X, 'Tag', 'SignalLine'), h.edge)
                else
                    plot(obj.signalAxis, X, avgSignal,...
                        'Color', [0.1 0.1 0.1], 'LineWidth', 0.9,... 
                        'Tag', 'SignalLine');
                end
            end
                  
            % Adjust the axes
            if obj.autoX
                xlim(obj.signalAxis, [obj.xpts(1), obj.xpts(end)]);
                maxVal = max(max(abs(allSignals), [], 'omitnan'), [], 'omitnan');
            else
                xLimits = [...
                    str2double(get(findByTag(obj.figureHandle, 'xLim1'), 'String')),...
                    str2double(get(findByTag(obj.figureHandle, 'xLim2'), 'String'))];
                xlim(obj.signalAxis, xLimits);
                xLimits = obj.FRAME_RATE * xLimits;
                maxVal = max(max(abs(allSignals(xLimits(1):xLimits(2), :)), [], 'omitnan'), [], 'omitnan');
            end
            if maxVal < 1
                maxVal = 1;
            end
            obj.stimPatch.YData = maxVal * [1 1 -1 -1];
            ylim(obj.signalAxis, [-maxVal, maxVal]);

        end
    end

    methods (Access = private)

        function onKeyPress(obj, ~, evt)
            % ONKEYPRESS
            
            switch evt.Key
                case 'leftarrow'
                    if ismember('control', evt.Modifier)
                        obj.changeTab(-1);
                        return
                    end
                    
                    if ismember('shift', evt.Modifier)
                        obj.currentRoi = obj.currentRoi - 10;
                    else
                        obj.currentRoi = obj.currentRoi - 1;
                    end
                    if obj.currentRoi < 1
                        obj.currentRoi = 1;
                        return;
                    end

                case 'rightarrow'
                    if ismember('control', evt.Modifier)
                        obj.changeTab(1);
                    end
                    
                    if ismember('shift', evt.Modifier)
                        obj.currentRoi = obj.currentRoi + 10;
                    else
                        obj.currentRoi = obj.currentRoi + 1;
                    end
                    if obj.currentRoi > obj.numROIs
                        obj.currentRoi = obj.numROIs;
                        return;
                    end

                otherwise
                    return;
            end

            obj.changeRoi();
        end
        
        function changeTab(obj, dir)
            currentTab = obj.getCurrentTabIndex();
            if dir == -1
                if currentTab == 1
                    return;
                else
                    newTabIndex = currentTab - 1;
                end
            elseif dir == 1
                if currentTab == 2
                    return;
                else
                    newTabIndex = currentTab + 1;
                end 
            end 
            h = findobj(obj.figureHandle, 'Type', 'uitabgroup');
            h.SelectedTab = findobj(obj.figureHandle,... 
                'Type', 'uitab', 'Tag', num2str(newTabIndex));
        end
        
        function ind = getCurrentTabIndex(obj)
            h = findobj(obj.figureHandle, 'Type', 'uitabgroup');
            ind = str2double(h.SelectedTab.Tag);
        end
        
        function onChanged_Number(~, src, ~)
            % ONCHANGED_NUMBER
            %   Generic callback to validate numeric inputs to edit fields
            % -------------------------------------------------------------
            
            tf = UiUtility.isValidNumber(src.String);
            if tf 
                set(src, 'ForegroundColor', 'k');
            else  % Change color to notify user of invalid input
                set(src, 'ForegroundColor', 'r');
            end
        end

        function onEdit_ROI(obj, src, ~)
            try
                newRoi = str2double(src.String);
                set(src, 'ForegroundColor', 'k', 'FontWeight', 'normal');
            catch
                set(src, 'ForegroundColor', 'r', 'FontWeight', 'bold');
            end
            obj.currentRoi = newRoi;
            obj.changeRoi();
            set(src, 'String', '');
        end

        function onEdit_HPCut(obj, src, ~)
            if isempty(src.String)
                obj.hpCut = [];
                return
            end
            
            if obj.checkNumericInput(src)
                obj.hpCut = str2double(src.String);
                obj.changeRoi();
            else
                obj.hpCut = [];
            end
        end
        
        function onEdit_LPCut(obj, src, ~)
            if isempty(src.String)
                obj.lpCut = [];
                return
            end
            
            if obj.checkNumericInput(src)
                obj.lpCut = str2double(src.String);
                obj.changeRoi();
            else
                obj.lpCut = [];
            end
        end
        
        function onCheck_Epoch(obj, src, ~)
            ind = str2double(src.Tag);
            if src.Value
                obj.includedEpochs(ind) = true;
            else
                obj.includedEpochs(ind) = false;
            end
            obj.changeRoi();
        end

        function onUser_ChangedPlot(obj, ~, ~)
            obj.changeRoi();
        end
        
        function onCheck_AutoAxis(obj, src, ~)
            % ONCHECK_AUTOAXIS
            % -------------------------------------------------------------
            
            obj.autoX = src.Value;

            if src.Value
                flag = 'off';
            else
                flag = 'on';
            end

            set(findByTag(obj.figureHandle, [lower(src.Tag(end)), 'Lim1']),...
                'Enable', flag);
            set(findByTag(obj.figureHandle, [lower(src.Tag(end)), 'Lim2']),...
                'Enable', flag);
        end

        function onPush_ExportFigure(obj, src, ~)
            newAxes = exportFigure(obj.signalAxis);
            txt = [obj.titleStr, sprintf(' ROI %u', obj.currentRoi)];

            title(newAxes, txt, 'Interpreter', 'none');
            figPos(newAxes.Parent, 0.8, 0.8);
            axis(newAxes, 'square');
            tightfig(newAxes.Parent);
            
            if strcmp(src.String, 'Save Figure')
                drawnow;
                txt = [txt, ' dff'];
                print(newAxes.Parent, [txt, '.png'], '-dpng', '-r600');
                delete(newAxes.Parent);
                fprintf('Saved as %s\n', [txt, '.png']);
            end
        end
        
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'ROI Viewer', ...
                'Color', 'w', ...
                'NumberTitle', 'off', ...
                'DefaultUicontrolBackgroundColor', 'w', ...
                'DefaultUicontrolFontSize', 10, ...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'KeyPressFcn', @obj.onKeyPress);

            mainLayout = uix.HBox('Parent', obj.figureHandle, ...
                'BackgroundColor', 'w');
            tabGroup = uitabgroup('Parent', mainLayout);
            uiLayout = uix.VBox(...
                'Parent', uitab(tabGroup, 'Title', 'A', 'Tag', '1'),...
                'BackgroundColor', 'w',...
                'Padding', 10);
            prefLayout = uix.VBox(...
                'Parent', uitab(tabGroup, 'Title', 'B', 'Tag', '2'),...
                'BackgroundColor', 'w',...
                'Padding', 10);
            obj.createPlotTab(prefLayout);
            signalLayout = uix.VBox('Parent', mainLayout);

            h = [];  % Track heights of ui components

            uicontrol(uiLayout, 'Style', 'text',... 
                'String', sprintf('ROI = 1 / %u', obj.numROIs),...
                'FontWeight', 'bold', 'Tag', 'CurrentRoi');
            uicontrol(uiLayout, 'Style', 'text',...
                'String', sprintf('QI = %.2f', obj.QI(1)),...
                'Tag', 'QI');
            uix.Empty('Parent', uiLayout, 'BackgroundColor', 'w');
            h = [h, 25, 20, 15];
            
            g = uix.Grid('Parent', uiLayout, ...
                'BackgroundColor', 'w');
            uicontrol(g, 'Style', 'text', 'String', 'ROI:');
            uicontrol(g, 'Style', 'text', 'String', 'Smooth:');
            uicontrol(g, 'Style', 'text', 'String', 'High pass');
            uicontrol(g, 'Style', 'text', 'String', 'Low pass');
            uicontrol(g, 'Style', 'text', 'String', 'Derivative');
            uicontrol(g, 'Style', 'text', 'String', 'ZScore');
            uicontrol(g, 'Style', 'text', 'String', 'Shaded error:');
            
            uicontrol(g, 'Style', 'edit', 'String', '', ...
                'Callback', @obj.onEdit_ROI);
            uicontrol(g, 'Style', 'edit', 'String', '1', 'Tag', 'Smooth', ...
                'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'HPCut',...
                'Callback', @obj.onEdit_HPCut);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'LPCut', ...
                'Callback', @obj.onEdit_LPCut);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'dfdt', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'ZScore', 'Callback', @obj.onUser_ChangedPlot,...
                'Enable', onOff(~isempty(obj.signalsZ)));
            uicontrol(g, 'Style', 'check', 'Value', 0,...
                'Tag', 'ShadedError', 'Callback', @obj.onUser_ChangedPlot);
            set(g, 'Heights', [-1 -1 -1 -1 -1 -1], 'Widths', [-1.3 -1]);            
            uix.Empty('Parent', uiLayout, 'BackgroundColor', 'w');
            h = [h, 150, -1];
            
            if numel(obj.epochIDs) > 1
                co = pmkmp(numel(obj.epochIDs), 'CubicL');
            else
                co = [0, 0, 0.3];
            end
            g = uix.Grid('Parent', uiLayout, 'BackgroundColor', 'w');
            numRows = ceil(numel(obj.epochIDs) / 2);
            for i = 1:numel(obj.epochIDs)
                uicontrol(g, 'Style', 'check', 'Value', 1,... 
                    'String', num2str(obj.epochIDs(i)),...
                    'ForegroundColor', co(i, :), 'Tag', num2str(i),... 
                    'Callback', @obj.onCheck_Epoch);
            end
            try
                set(g, 'Heights', -1 * ones(1, numRows), 'Widths', [-1 -1]);
            end
            h = [h, numRows * 25];
            
            set(uiLayout, 'Heights', h);

            % Signal display
            obj.signalAxis = axes(uipanel(signalLayout, 'BackgroundColor', 'w'));
            hold(obj.signalAxis, 'on');
            if ~isempty(obj.stimWindow)
                obj.stimPatch = patch(...
                    'XData', [obj.stimWindow, fliplr(obj.stimWindow)], 'YData', [1 1 -1 -1],...
                    'Parent', obj.signalAxis, 'FaceColor', [0.3 0.3 1],... 
                    'FaceAlpha', 0.15, 'EdgeColor', 'none');
            end
            plot(obj.signalAxis, [obj.xpts(1), obj.xpts(end)], [0 0],...
                'Color', [0.4, 0.4, 0.4]);
            grid(obj.signalAxis, 'on');
            xlabel(obj.signalAxis, 'Time (sec)');
            ylabel(obj.signalAxis, 'Signal (dF/F)');
            obj.updateSignalPlot();
            
            if ~isempty(obj.stim)
                ax = axes(uipanel(signalLayout, 'BackgroundColor', 'w'));
                plot(ax, linspace(obj.xpts(1), obj.xpts(end), numel(obj.stim)), obj.stim,...
                    'Color', [0.1 0.1 0.5], 'LineWidth', 0.75);
                axis(ax, 'off'); axis(ax, 'tight');
                set(signalLayout, 'Heights', [-3, -1]);
            end

            set(mainLayout, 'Widths', [-1, -3]);
        end
        
        
        
        function createPlotTab(obj, parentHandle)
            heights = [];
            
            uix.Empty('Parent', parentHandle,...
                'BackgroundColor', 'w');
            UiUtility.horizontalBoxWithTwoCells(...
                parentHandle, 'X Axis Limits:',...
                'xLim1', 'xLim2',...
                'Enable', 'off',...
                'Callback', @obj.onChanged_Number);
            uicontrol(parentHandle,...
                'Style', 'check',...
                'String', 'Auto X Axis',...
                'Value', true,...
                'Tag', 'AutoX',...
                'Callback', @obj.onCheck_AutoAxis);
            heights = [heights, -1, 40, 20];
            
            uix.Empty('Parent', parentHandle, 'BackgroundColor', 'w');
            exportLayout = uix.HBox('Parent', parentHandle,...
                'BackgroundColor', 'w');
            uicontrol(exportLayout, 'Style', 'push', 'String', 'Export',...
                'Callback', @obj.onPush_ExportFigure);
            uicontrol(exportLayout, 'Style', 'push', 'String', 'Save',...
                'Callback', @obj.onPush_ExportFigure);
            uix.Empty('Parent', parentHandle, 'BackgroundColor', 'w');
            heights = [heights, -1, 30, -1];
            
            set(parentHandle, 'Heights', heights);
        end
    end

    methods (Static)
        function isValid = checkNumericInput(src)
            try
                x = str2double(src.Value);  %#ok
                set(src, 'ForegroundColor', 'k');
                isValid = true;
            catch
                set(src, 'ForegroundColor', 'r');
                isValid = false;
            end
        end
    end
end