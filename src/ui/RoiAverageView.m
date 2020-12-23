classdef RoiAverageView < handle

    properties (SetAccess = private)
        Dataset
        epochIDs
        signals
        stim
        xpts
        
        hpCut
        lpCut
        numBins
        includedEpochs
        stimWindow

        currentRoi
        stimPatch
        titleStr
        signalAxis
        figureHandle
    end

    properties (Hidden, Dependent = true)
        useMedian
        shadeError
    end

    methods 
        function obj = RoiAverageView(data, epochIDs, bkgdWindow, stimWindow, titleStr, stim)

            obj.Dataset = data;
            if iscell(epochIDs)
                epochIDs = epochIDs{:};
            end
            obj.epochIDs = epochIDs;
            
            if nargin < 5
                titleStr = char(data.experimentDate);
            end
            obj.titleStr = titleStr;
            if nargin == 6
                obj.stim = stim;
            end
            
            % [obj.signals, obj.xpts] = data.getStimulusResponses(epochIDs, bkgdWindow);
            signals = zeros(data.numROIs, data.imSize(3), numel(epochIDs));
            for i = 1:numel(epochIDs)
                [A, xpts] = data.getEpochResponses(epochIDs(i), bkgdWindow, true);
                signals(:, :, i) = A;
            end
            obj.signals = signals;
            obj.xpts = xpts;
            obj.stimWindow = (1/data.frameRate) * stimWindow;

            obj.includedEpochs = true(1, numel(obj.epochIDs));
            obj.currentRoi = 1;
            
            obj.createUi();
        end
    end

    methods  % Dependent set/get methods
        function useMedian = get.useMedian(obj)
            h = findobj(obj.figureHandle, 'Tag', 'UseMedian');
            useMedian = h.Value;
        end
        
        function shadeError = get.shadeError(obj)
            h = findobj(obj.figureHandle, 'Tag', 'ShadedError');
            shadeError = h.Value;
        end
    end

    methods (Access = private)

        function changeRoi(obj, varargin)
            obj.updateSignalPlot();

            set(findByTag(obj.figureHandle, 'CurrentRoi'), ...
                'String', sprintf('ROI = %u / %u', obj.currentRoi, obj.Dataset.numROIs));
        end

        function updateSignalPlot(obj)

            allSignals = squeeze(obj.signals(obj.currentRoi, :, obj.includedEpochs));
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
            if ~isempty(h.String) &&~strcmp(h.String, '1')
                smoothFac = str2double(h.String);
                for i = 1:size(allSignals, 2)
                    response = padarray(allSignals(:, i), [smoothFac, 0], 0, 'both');
                    response = smooth(response, smoothFac);
                    response(1:smoothFac) = [];
                    response(end - smoothFac + 1:end) = [];
                    allSignals(:, i) = response;
                end
            end
            
            % Derivative if needed
            if get(findByTag(obj.figureHandle, 'dfdt'), 'Value')
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = gradient(allSignals(:, i));
                end
            end

            % Normalize if needed and adjust y-axis accordingly
            if ~isempty(obj.stimWindow)
                obj.stimPatch.YData = [1 1 -1 -1];
            end
            if get(findobj(obj.figureHandle, 'Tag', 'Norm'), 'Value')
                for i = 1:size(allSignals, 2)
                    % allSignals(:, i) = allSignals(:, i) / max(abs(allSignals(:, i)));
                    allSignals(:, i) = normalize(allSignals(:, i));
                end
                if ~isempty(obj.stimWindow)
                    obj.stimPatch.YData = [1 1 -1 -1];
                end
                ylim(obj.signalAxis, [-1 1]);
            else
                if ~isempty(obj.stimWindow)
                    maxVal = max(max(abs(allSignals)));
                        ylim(obj.signalAxis, [-maxVal, maxVal]);
                        obj.stimPatch.YData = maxVal * [1 1 -1 -1];
                end
            end

            % Bin data
            if ~isempty(obj.numBins)
                % allSignals2 = [];
                % N = floor(size(allSignals, 1) / obj.numBins);
                % for i = 1:size(allSignals, 2)
                %     allSignals2 = cat(2, allSignals2,...
                %         discretize(allSignals(:, i), N));
                % end
                % allSignals = allSignals2;
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = gaussfilt(obj.xpts, allSignals(:, i), obj.numBins);
                end
            end
            
            % Plot the individual signals, if necessary
            delete(findall(obj.signalAxis, 'Tag', 'SignalLine'));
            if ~obj.shadeError
                co = pmkmp(numel(obj.epochIDs), 'CubicL');
                co = co(obj.includedEpochs, :);
                for i = 1:size(allSignals, 2)
                    plot(obj.signalAxis, obj.xpts, allSignals(:, i),...
                        'Color', co(i,:), 'LineWidth', 0.55,... 
                        'Tag', 'SignalLine');
                end
            end

            % Calc and plot the average/median
            if nnz(obj.includedEpochs) > 1
                if obj.useMedian
                    avgSignal = mean(allSignals, 2);
                else
                    avgSignal = median(allSignals, 2);
                end
                if obj.shadeError
                    h = shadedErrorBar(obj.xpts, avgSignal,... 
                        std(allSignals, [], 2));
                    h.mainLine.Tag = 'SignalLine';
                    h.patch.Tag = 'SignalLine';
                    arrayfun(@(X) set(X, 'Tag', 'SignalLine'), h.edge)
                else
                    plot(obj.signalAxis, obj.xpts, avgSignal,...
                        'Color', [0.1 0.1 0.1], 'LineWidth', 0.9,... 
                        'Tag', 'SignalLine');
                end
            end
        end
    end

    methods (Access = private)

        function onKeyPress(obj, ~, evt)
            switch evt.Key

                case 'leftarrow'
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
                    if ismember('shift', evt.Modifier)
                        obj.currentRoi = obj.currentRoi + 10;
                    else
                        obj.currentRoi = obj.currentRoi + 1;
                    end
                    if obj.currentRoi > obj.Dataset.numROIs
                        obj.currentRoi = obj.Dataset.numROIs;
                        return;
                    end

                otherwise
                    return;
            end

            obj.changeRoi();
        end

        function onEdit_ROI(obj, src, ~)
            try
                newRoi = str2double(src.String);
                set(src, 'ForegroundColor', 'k');
            catch
                set(src, 'ForegroundColor', 'r');
            end
            obj.currentRoi = newRoi;
            obj.changeRoi();
            set(src, 'String', '');
        end

        function onEdit_BinData(obj, src, ~)
            if isempty(src.String)
                obj.numBins = [];
                obj.changeRoi();
                return
            end

            if obj.checkNumericInput(src)
                obj.numBins = str2double(src.String) * (obj.xpts(2)-obj.xpts(1));
                obj.changeRoi();
            else
                obj.numBins = [];
                src.String = '';
            end
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

        function onPush_ExportFigure(obj, src, ~)
            newAxes = exportFigure(obj.signalAxis);
            txt = [obj.titleStr, sprintf(' ROI %u', obj.currentRoi)];

            title(newAxes, txt, 'Interpreter', 'none');
            figPos(newAxes.Parent, 0.8, 0.8);
            axis(newAxes, 'square');
            tightfig(newAxes.Parent);
            
            if strcmp(src.String, 'Save Figure')
                drawnow;
                if ~get(findByTag(obj.figureHandle, 'Norm'), 'Value')
                    txt = [txt, ' dff'];
                end
                print(newAxes.Parent, [txt, '.png'], '-dpng', '-r600');
                delete(newAxes.Parent);
                fprintf('Saved as %s\n', [txt, '.png']);
            end
        end
        
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'RoiSignalView', ...
                'Color', 'w', ...
                'NumberTitle', 'off', ...
                'DefaultUicontrolBackgroundColor', 'w', ...
                'DefaultUicontrolFontSize', 10, ...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'KeyPressFcn', @obj.onKeyPress);

            mainLayout = uix.HBox('Parent', obj.figureHandle, ...
                'BackgroundColor', 'w');
            uiLayout = uix.VBox('Parent', mainLayout, ...
                'BackgroundColor', 'w', 'Padding', 10);
            signalLayout = uix.VBox('Parent', mainLayout);

            h = [];  % Track heights of ui components
            if ~isempty(obj.titleStr)
                uicontrol(uiLayout, 'Style', 'text', 'String', obj.titleStr);
                h = [h, 50];
            end

            uicontrol(uiLayout, 'Style', 'text',... 
                'String', sprintf('ROI = 1 / %u', obj.Dataset.numROIs),...
                'FontWeight', 'bold', 'Tag', 'CurrentRoi');
            uix.Empty('Parent', uiLayout, 'BackgroundColor', 'w');
            h = [h, 25, -1];
            
            g = uix.Grid('Parent', uiLayout, ...
                'BackgroundColor', 'w');
            uicontrol(g, 'Style', 'text', 'String', 'ROI:');
            uicontrol(g, 'Style', 'text', 'String', 'Smooth:');
            uicontrol(g, 'Style', 'text', 'String', 'Bin:');
            uicontrol(g, 'Style', 'text', 'String', 'High pass');
            uicontrol(g, 'Style', 'text', 'String', 'Low pass');
            uicontrol(g, 'Style', 'text', 'String', 'Normalize');
            uicontrol(g, 'Style', 'text', 'String', 'Derivative');
            uicontrol(g, 'Style', 'text', 'String', 'Median');
            uicontrol(g, 'Style', 'text', 'String', 'Shaded error:');
            
            uicontrol(g, 'Style', 'edit', 'String', '', ...
                'Callback', @obj.onEdit_ROI);
            uicontrol(g, 'Style', 'edit', 'String', '1', 'Tag', 'Smooth', ...
                'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'Bin',...
                'Callback', @obj.onEdit_BinData);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'HPCut',...
                'Callback', @obj.onEdit_HPCut);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'LPCut', ...
                'Callback', @obj.onEdit_LPCut);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'Norm', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'dfdt', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'UseMedian', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'Value', 0,...
                'Tag', 'ShadedError', 'Callback', @obj.onUser_ChangedPlot);
            set(g, 'Heights', [-1 -1 -1 -1 -1], 'Widths', [-1.3 -1]);            
            uix.Empty('Parent', uiLayout, 'BackgroundColor', 'w');
            h = [h, 170, -1];
            
            co = pmkmp(numel(obj.epochIDs), 'CubicL');
            g = uix.Grid('Parent', uiLayout, 'BackgroundColor', 'w');
            numRows = ceil(numel(obj.epochIDs) / 2);
            for i = 1:numel(obj.epochIDs)
                uicontrol(g, 'Style', 'check', 'Value', 1,... 
                    'String', num2str(obj.epochIDs(i)),...
                    'ForegroundColor', co(i, :), 'Tag', num2str(i),... 
                    'Callback', @obj.onCheck_Epoch);
            end
            set(g, 'Heights', -1 * ones(1, numRows), 'Widths', [-1 -1]);
            h = [h, numRows * 25];

            exportLayout = uix.HBox('Parent', uiLayout,...
                'BackgroundColor', 'w');
            uicontrol(exportLayout, 'Style', 'push', 'String', 'Export',...
                'Callback', @obj.onPush_ExportFigure);
            uicontrol(exportLayout, 'Style', 'push', 'String', 'Save',...
                'Callback', @obj.onPush_ExportFigure);
            uix.Empty('Parent', uiLayout, 'BackgroundColor', 'w');
            h = [h, 30, -1];
            set(uiLayout, 'Heights', h);

            % Signal display
            obj.signalAxis = axes(uipanel(signalLayout, 'BackgroundColor', 'w'));
            hold(obj.signalAxis, 'on');
            if ~isempty(obj.stimWindow)
                obj.stimPatch = patch(...
                    'XData', [obj.stimWindow, fliplr(obj.stimWindow)], 'YData', [1 1 -1 -1],...
                    'Parent', obj.signalAxis, 'FaceColor', [0.3 0.3 1], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
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
                    'b', 'LineWidth', 0.75);
                axis(ax, 'off'); axis(ax, 'tight');
                set(signalLayout, 'Heights', [-3, -1]);
            end

            set(mainLayout, 'Widths', [-1, -3]);
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