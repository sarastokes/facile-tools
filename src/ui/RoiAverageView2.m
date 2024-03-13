classdef RoiAverageView2 < handle

    events
        RoiChanged
    end

    properties (SetAccess = private)
        Dataset
        epochIDs
        signals
        signalsZ
        stim
        xpts
        QI

        hpCut
        lpCut
        numBins
        butterFreq
        includedEpochs
        stimWindow
        bkgdWindow
        otherStat

        autoX

        currentRoi

        % Plot components
        stimPatch
        titleStr
        signalAxis
        roiAxis
        roiHandle
        figureHandle
    end

    properties (SetAccess = private)
        avgSignal
        avgX
        freqView
    end

    properties (Hidden, Dependent = true)
        useMedian
        shadeError
    end

    properties (Hidden, Constant)
        SAMPLE_RATE = 25
    end

    methods
        function obj = RoiAverageView2(data, epochIDs, bkgdWindow, stimWindow, titleStr, stim)

            obj.Dataset = data;
            if iscell(epochIDs)
                epochIDs = epochIDs{:};
            end
            obj.epochIDs = epochIDs;

            if nargin < 5
                titleStr = char(data.experimentDate);
            end
            obj.titleStr = titleStr;
            if nargin > 5
                obj.stim = stim;
            end

            [obj.signals, obj.xpts] = data.getEpochResponses(epochIDs, bkgdWindow);
            try
                obj.signalsZ = roiZScores(data.getEpochResponses(epochIDs, []), bkgdWindow);
            catch
                obj.signalsZ = [];
            end
            obj.stimWindow = (1/data.frameRate) * stimWindow;
            obj.bkgdWindow = bkgdWindow;

            % Check for NaNs
            if nnz(isnan(obj.signals)) > 0
                warning('Dataset contains %u NaNs that will be filled',...
                    nnz(isnan(obj.signals)));
            end

            % Get the quality index from smoothed signals
            signalsSmoothed = zeros(size(obj.signals));
            for i = 1:size(obj.signals, 1)
                for j = 1:size(obj.signals, 3)
                    signalsSmoothed(i, :, j) = mysmooth(obj.signals(i, :, j), 100);
                end
            end
            obj.QI = qualityIndex(signalsSmoothed);

            obj.includedEpochs = true(1, numel(obj.epochIDs));
            obj.currentRoi = 1;
            obj.autoX = true;

            obj.createUi();
        end

        function out = getAvgSignal(obj)
            out = obj.avgSignal;
        end

        function setTitle(obj, str)
            set(obj.figureHandle, 'Name', str);
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

            if obj.getCurrentTabIndex() == 3
                obj.lazyShowRois();
            end

            set(findByTag(obj.figureHandle, 'CurrentRoi'), ...
                'String', sprintf('%u / %u', obj.currentRoi, obj.Dataset.numROIs));
            if ~isempty(obj.Dataset.roiUIDs)
                set(findByTag(obj.figureHandle, 'CurrentUid'),...
                    'String', char(obj.Dataset.roiUIDs{obj.currentRoi, 'UID'}));
            end
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
                if isempty(obj.bkgdWindow)
                    ylabel(obj.signalAxis, 'Response (F)');
                else
                    ylabel(obj.signalAxis, 'Response (dF/F)');
                end
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

            % Smooth each signal if needed
            h = findobj(obj.figureHandle, 'Tag', 'Smooth');
            if ~isempty(h.String) && ~ismember(h.String, {'0', '1'})
                smoothFac = str2double(h.String);
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = mysmooth(allSignals(:, i), smoothFac);
                end
            else
                smoothFac = 1;
            end

            hpFlag = ~isempty(obj.hpCut) && obj.hpCut ~= 0;
            lpFlag = ~isempty(obj.lpCut) && obj.lpCut ~= 0;

            % Filtering
            if hpFlag && lpFlag     % Bandpass filter
                for i = 1:size(allSignals,2)
                    allSignals(:,i) = bandpass(allSignals(:,i), ...
                        sort([obj.hpCut, obj.lpCut]), obj.SAMPLE_RATE);
                end
            elseif hpFlag           % Highpass filter
                allSignals = signalHighPassFilter(allSignals', obj.hpCut, obj.SAMPLE_RATE);
                if ~isempty(obj.bkgdWindow)
                    allSignals = signalBaselineCorrect(allSignals, obj.bkgdWindow)';
                else
                    allSignals = allSignals';
                    allSignals = allSignals - mean(allSignals,1);
                end
            elseif lpFlag            % Lowpass filter
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = lowPassFilter(...
                        allSignals(:, i), obj.lpCut, obj.xpts(2)-obj.xpts(1));
                end
            end

            % Derivative if needed
            if get(findByTag(obj.figureHandle, 'dfdt'), 'Value')
                for i = 1:size(allSignals, 2)
                    allSignals(:, i) = gradient(allSignals(:, i));
                end
            end

            % Normalize if needed
            if get(findobj(obj.figureHandle, 'Tag', 'Norm'), 'Value')
                %if ~isempty(obj.bkgdWindow)
                %    allSignals = signalNormalize(allSignals', 2, obj.bkgdWindow)';
                %if isempty(obj.stimWindow)
                    for i = 1:size(allSignals,2)
                        allSignals(:,i) = rescale(allSignals(:,i));
                        allSignals(:,i) = allSignals(:,i) - mean(allSignals(window2idx(obj.bkgdWindow),i));
                    end
                    %allSignals = allSignals - mean(allSignals(window2idx(obj.bkgdWindow),:), 1);
                %else
                    %allSignals = bsxfun(@minus, allSignals,...
                    %    median(allSignals(smoothFac+1 : (obj.stimWindow(1)/(1/obj.Dataset.frameRate)), :), 1));
                %end
            end

            % Bin data
            if ~isempty(obj.numBins) && obj.numBins ~= 0
                for i = 1:size(allSignals, 2)
                    allSignals(:,i) = movmean(allSignals(:,i), obj.numBins);
                end
            end

            % Apply butterworth filter
            if ~isempty(obj.butterFreq) && obj.butterFreq ~= 0
                allSignals = signalButterFilter(allSignals', obj.SAMPLE_RATE, 3, obj.butterFreq)';
            end

            % Deconvolve 
            if get(findByTag(obj.figureHandle, 'deconv'), 'Value')
                allSignals = signalDeconv6s(allSignals', 1.5, obj.SAMPLE_RATE)';
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
                elseif numel(X) > size(allSignals, 1)
                    X = X(1:size(allSignals,1));
                end
                for i = 1:size(allSignals, 2)
                    plot(obj.signalAxis, X, allSignals(1:numel(X), i),...
                        'Color', co(i,:), 'LineWidth', 0.55,...
                        'Tag', 'SignalLine');
                end
            end

            % Calc and plot the average/median
            if nnz(obj.includedEpochs) > 1
                if obj.useMedian
                    avgSignal = median(allSignals, 2);
                else
                    avgSignal = mean(allSignals, 2, 'omitnan');
                end
                if obj.shadeError
                    axes(obj.signalAxis);
                    h = shadedErrorBar(X, avgSignal,...
                        std(allSignals, [], 2));
                    h.mainLine.Tag = 'SignalLine';
                    h.patch.Tag = 'SignalLine';
                    arrayfun(@(X) set(X, 'Tag', 'SignalLine'), h.edge)
                else
                    plot(obj.signalAxis, X, avgSignal(1:numel(X)),...
                        'Color', [0.1 0.1 0.1], 'LineWidth', 0.9,...
                        'Tag', 'SignalLine');
                end
                obj.avgSignal = avgSignal(1:numel(X));
                obj.avgX = X;
            else
                obj.avgSignal = allSignals(1:numel(X));
                obj.avgX = X;
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
                xLimits = obj.Dataset.frameRate * xLimits;
                if ~isempty(obj.numBins) && obj.numBins ~= 0
                    xLimits = [ceil(xLimits(1) / obj.numBins), floor(xLimits(2) / obj.numBins)];
                end
                maxVal = max(max(abs(allSignals(xLimits(1):xLimits(2), :)), [], 'omitnan'), [], 'omitnan');
            end
            if maxVal < 1
                maxVal = 1;
            end
            h = findall(gcf, 'Tag', 'StimPatch');
            for i = 1:numel(h)
                h(i).YData = [1 1 -1 -1];
            end


            if get(findobj(obj.figureHandle, 'Tag', 'ZScore'), 'Value')
                if maxVal < 1
                    ylim(obj.signalAxis, [-1 1]);
                else
                    roundYAxisLimits(obj.signalAxis, [0.5, 1]);
                    y = ylim(obj.signalAxis);
                    for i = 1:numel(h)
                        h(i).YData = [y(1) y(1) y(2) y(2)];
                    end
                end
            else
                ylim(obj.signalAxis, [-maxVal, maxVal]);

                for i = 1:numel(h)
                    h(i).YData = maxVal * [1 1 -1 -1];
                end
            end

            notify(obj, 'RoiChanged');
        end

        function lazyShowRois(obj)
            % LAZYSHOWROIS
            mask = obj.Dataset.rois == obj.currentRoi;
            set(obj.roiHandle, 'CData', mask, 'AlphaData', 0.5 * mask);
        end
    end

    methods (Access = private)

        function onKeyPress(obj, ~, evt)
            % ONKEYPRESS

            if ismember('ctrl', evt.Modifier)
                obj.changeTab(1);
                return
            end

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
                case 'n'
                    h = findobj(obj.figureHandle, 'Tag', 'Norm');
                    if h.Value
                        h.Value = 0;
                    else
                        h.Value = 1;
                    end
                case 'f'
                    obj.freqView = FrequencyView(obj);
                otherwise
                    return;
            end

            obj.changeRoi();
        end

        function onPushDividerArrow(obj, src, ~)
            % ONPUSHDIVIDERARROW
            switch src.String
                case 'Expand ->'
                    h = findByTag(obj.figureHandle, 'MainLayout');
                    set(h, 'Widths', [-1, -1.5]);
                    set(src, 'String', '<- Condense');
                case '<- Condense'
                    h = findByTag(obj.figureHandle, 'MainLayout');
                    set(h, 'Widths', [-1, -3]);
                    set(src, 'String', 'Expand ->');
            end
        end

        function changeTab(obj, dir)
            % CHANGETAB
            currentTab = obj.getCurrentTabIndex();
            if dir == -1
                if currentTab == 1
                    return;
                else
                    newTabIndex = currentTab - 1;
                end
            elseif dir == 1
                if currentTab == 3
                    newTabIndex = 1;
                else
                    newTabIndex = currentTab + 1;
                end
            end
            h = findobj(obj.figureHandle, 'Type', 'uitabgroup');
            h.SelectedTab = findobj(obj.figureHandle,...
                'Type', 'uitab', 'Tag', num2str(newTabIndex));
            if currentTab == 3
                obj.lazyShowRois()
            end
        end

        function ind = getCurrentTabIndex(obj)
            % GETCURRENTTABINDEX
            h = findobj(obj.figureHandle, 'Type', 'uitabgroup');
            ind = str2double(h.SelectedTab.Tag);
        end

        function onChanged_Number(~, src, ~)
            % ONCHANGED_NUMBER
            %   Generic callback to validate numeric inputs to edit fields
            % -------------------------------------------------------------

            tf = ao.ui.UiUtility.isValidNumber(src.String);
            if tf
                set(src, 'ForegroundColor', 'k');
            else  % Change color to notify user of invalid input
                set(src, 'ForegroundColor', 'r');
            end
        end

        function onEdit_ROI(obj, src, ~)

            if obj.isUID(src.String)
                newRoi = find(obj.Dataset.roiUIDs.UID == upper(src.String));
                if isempty(newRoi)
                    set(src, 'ForegroundColor', 'r', 'FontWeight', 'bold');
                    return
                end
                set(src, 'ForegroundColor', 'k', 'FontWeight', 'normal');
            else
                try
                    newRoi = str2double(src.String);
                    set(src, 'ForegroundColor', 'k', 'FontWeight', 'normal');
                catch
                    set(src, 'ForegroundColor', 'r', 'FontWeight', 'bold');
                    return
                end
            end
            obj.currentRoi = newRoi;
            obj.changeRoi();
            set(src, 'String', '');
        end

        function onEdit_BinData(obj, src, ~)
            if isempty(src.String)
                obj.numBins = 0;
                obj.changeRoi();
                return
            end

            if obj.checkNumericInput(src)
                obj.numBins = str2double(src.String); % * (obj.xpts(2)-obj.xpts(1));
                fprintf('Binned sample rate is %.3f Hz\n',...
                    obj.Dataset.frameRate / obj.numBins);
                obj.changeRoi();
            else
                obj.numBins = 0;
                src.String = '';
            end
        end

        function onEdit_ButterCutoff(obj, src, ~)
            if isempty(src.String)
                obj.butterFreq = [];
                return
            end
        
            if obj.checkNumericInput(src)
                obj.butterFreq = str2double(src.String);
                obj.changeRoi();
            else
                obj.butterFreq = [];
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
                'Name', 'ROI Average View', ...
                'Color', 'w', ...
                'NumberTitle', 'off', ...
                'DefaultUicontrolBackgroundColor', 'w', ...
                'DefaultUicontrolFontSize', 10, ...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'KeyPressFcn', @obj.onKeyPress);

            mainLayout = uix.HBox('Parent', obj.figureHandle, ...
                'BackgroundColor', 'w', 'Tag', 'MainLayout');
            leftPanel = uix.VBox('Parent', mainLayout,...
                'BackgroundColor', 'w');

            h = [];  % Tracks heights of ui components
            uicontrol(leftPanel, 'Style', 'text',...
                'String', sprintf('1 / %u', obj.Dataset.numROIs),...
                'FontWeight', 'bold', 'Tag', 'CurrentRoi');
            h = [h, 20];
            if ~isempty(obj.Dataset.roiUIDs)
                uicontrol(leftPanel, 'Style', 'text',...
                    'String', char(obj.Dataset.roiUIDs{1,'UID'}),...
                    'FontWeight', 'bold', 'Tag', 'CurrentUid');
                h = [h, 20];
            end
            uicontrol(leftPanel, 'Style', 'text',...
                'String', sprintf('QI = %.2f', obj.QI(1)),...
                'Tag', 'QI');
            uix.Empty('Parent', leftPanel, 'BackgroundColor', 'w');
            h = [h, 20, 10];

            roiSelectBox = uix.HBox('Parent', leftPanel,...
                'BackgroundColor', 'w');
            uix.Empty('Parent', roiSelectBox, 'BackgroundColor', 'w');
            uicontrol(roiSelectBox, 'Style', 'text', 'String', 'ROI:');
            uicontrol(roiSelectBox, 'Style', 'edit', 'String', '', ...
                'Callback', @obj.onEdit_ROI);
            uix.Empty('Parent', roiSelectBox, 'BackgroundColor', 'w');
            set(roiSelectBox, 'Widths', [10, -1, -1, 10])
            uix.Empty('Parent', leftPanel, 'BackgroundColor', 'w');
            h = [h, 20, 10];
            tabGroup = uitabgroup('Parent', leftPanel);
            set(leftPanel, 'Heights', [h, -1]);

            % Create the tabs
            uiLayout = uix.VBox(...
                'Parent', uitab(tabGroup, 'Title', 'A', 'Tag', '1'),...
                'BackgroundColor', 'w',...
                'Padding', 10);
            obj.createMainTab(uiLayout);
            prefLayout = uix.VBox(...
                'Parent', uitab(tabGroup, 'Title', 'B', 'Tag', '2'),...
                'BackgroundColor', 'w',...
                'Padding', 10);
            obj.createPlotTab(prefLayout);
            roiLayout = uix.VBox(...
                'Parent', uitab(tabGroup, 'Title', 'C', 'Tag', '3'),...
                'BackgroundColor', 'w',...
                'Padding', 10);
            obj.createRoiTab(roiLayout);

            signalLayout = uix.VBox('Parent', mainLayout);
            obj.createSignalView(signalLayout);


            set(mainLayout, 'Widths', [-1, -3]);
        end

        function createSignalView(obj, parentHandle)
             % Signal display
            obj.signalAxis = axes(uipanel(parentHandle, 'BackgroundColor', 'w'));
            hold(obj.signalAxis, 'on');
            if ~isempty(obj.stimWindow)
                for i = 1:size(obj.stimWindow, 1)
                    obj.stimPatch = patch(...
                        'XData', [obj.stimWindow(i,:), fliplr(obj.stimWindow(i,:))], ...
                        'YData', [1 1 -1 -1], 'Tag', 'StimPatch',...
                        'Parent', obj.signalAxis, 'FaceColor', [0.3 0.3 1], ...
                        'FaceAlpha', 0.15, 'EdgeColor', 'none');
                end
            end
            plot(obj.signalAxis, [obj.xpts(1), obj.xpts(end)], [0 0],...
                'Color', [0.4, 0.4, 0.4]);
            grid(obj.signalAxis, 'on');
            xlabel(obj.signalAxis, 'Time (sec)');
            ylabel(obj.signalAxis, 'Signal (dF/F)');
            obj.updateSignalPlot();

            if ~isempty(obj.stim)
                ax = axes(uipanel(parentHandle, 'BackgroundColor', 'w'));
                if isvector(obj.stim)
                    plot(ax, linspace(obj.xpts(1), obj.xpts(end), numel(obj.stim)), obj.stim,...
                        'Color', [0.05 0.05 0.4], 'LineWidth', 1.5);
                elseif istable(obj.stim)
                    hold(ax, 'on');
                    plot(ax, obj.xpts, obj.stim.R(1:numel(obj.xpts)), ...
                        'Color', hex2rgb('ff4040'), 'LineWidth', 1.5);
                    plot(ax, obj.xpts, obj.stim.G(1:numel(obj.xpts)), ...
                        'Color', hex2rgb('00cc4d'), 'LineWidth', 1.5);
                    plot(ax, obj.xpts, obj.stim.B(1:numel(obj.xpts)), ...
                        'Color', hex2rgb('334de6'), 'LineWidth', 1.5);
                else  % multiple traces, one per epoch
                    if numel(obj.epochIDs) > 1
                        co = pmkmp(size(obj.stim, 2), 'CubicL');
                    else
                        co = [0, 0, 0.3];
                    end
                    for i = 2:size(obj.stim, 2)
                        plot(ax, obj.xpts, obj.stim(1:numel(obj.xpts), i), 'Color', co(i,:));
                    end
                end
                axis(ax, 'off'); axis(ax, 'tight');
                linkaxes([obj.signalAxis, ax], 'x');
                set(parentHandle, 'Heights', [-4, -1]);
            end
        end

        function createMainTab(obj, parentHandle)

            h = [];  % Track heights of ui components
            g = uix.Grid('Parent', parentHandle, ...
                'BackgroundColor', 'w');
            uicontrol(g, 'Style', 'text', 'String', 'Smooth:');
            uicontrol(g, 'Style', 'text', 'String', 'Bin:');
            uicontrol(g, 'Style', 'text', 'String', 'High pass');
            uicontrol(g, 'Style', 'text', 'String', 'Low pass');
            uicontrol(g, 'Style', 'text', 'String', 'Butter');
            uicontrol(g, 'Style', 'text', 'String', 'Normalize');
            uicontrol(g, 'Style', 'text', 'String', 'Derivative');
            uicontrol(g, 'Style', 'text', 'String', 'Deconv');
            uicontrol(g, 'Style', 'text', 'String', 'Median');
            uicontrol(g, 'Style', 'text', 'String', 'ZScore');
            uicontrol(g, 'Style', 'text', 'String', 'Shaded error:');

            uicontrol(g, 'Style', 'edit', 'String', '1', 'Tag', 'Smooth', ...
                'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'Bin',...
                'Callback', @obj.onEdit_BinData);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'HPCut',...
                'Callback', @obj.onEdit_HPCut);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'LPCut', ...
                'Callback', @obj.onEdit_LPCut);
            uicontrol(g, 'Style', 'edit', 'String', '', 'Tag', 'ButterCutoff', ...
                'Callback', @obj.onEdit_ButterCutoff);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'Norm', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'dfdt', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'deconv', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'UseMedian', 'Callback', @obj.onUser_ChangedPlot);
            uicontrol(g, 'Style', 'check', 'String', '',...
                'Tag', 'ZScore', 'Callback', @obj.onUser_ChangedPlot,...
                'Enable', onOff(~isempty(obj.signalsZ)));
            uicontrol(g, 'Style', 'check', 'Value', 0,...
                'Tag', 'ShadedError', 'Callback', @obj.onUser_ChangedPlot);
            set(g, 'Heights', [-1 -1 -1 -1 -1 -1 -1], 'Widths', [-1.3 -1]);
            uix.Empty('Parent', parentHandle, 'BackgroundColor', 'w');
            h = [h, 170, -1];

            if numel(obj.epochIDs) > 1
                co = pmkmp(numel(obj.epochIDs), 'CubicL');
            else
                co = [0, 0, 0.3];
            end
            g = uix.Grid('Parent', parentHandle, 'BackgroundColor', 'w');
            numRows = ceil(numel(obj.epochIDs) / 2);
            for i = 1:numel(obj.epochIDs)
                uicontrol(g, 'Style', 'check', 'Value', 1,...
                    'String', num2str(obj.epochIDs(i)),...
                    'ForegroundColor', co(i, :), 'Tag', num2str(i),...
                    'Callback', @obj.onCheck_Epoch);
            end
            try  %#ok<TRYNC>
                set(g, 'Heights', -1 * ones(1, numRows), 'Widths', [-1 -1]);
            end
            h = [h, numRows * 25];

            set(parentHandle, 'Heights', h);
        end

        function createRoiTab(obj, parentHandle)
            % Roi display
            roiLayout = uix.VBox('Parent', parentHandle, 'BackgroundColor', 'w');
            obj.roiAxis = axes(uipanel(roiLayout, 'BackgroundColor', 'w'));
            obj.roiHandle = roiOverlay(obj.Dataset.avgImage, obj.Dataset.rois == obj.currentRoi,...
                'Colormap', 'bone', 'Parent', obj.roiAxis);
            uicontrol(roiLayout, 'Style', 'push',...
                'String', 'Expand ->',...
                'Callback', @obj.onPushDividerArrow);
            set(roiLayout, 'Heights', [-1, 20]);
        end

        function createPlotTab(obj, parentHandle)
            heights = [];

            uix.Empty('Parent', parentHandle,...
                'BackgroundColor', 'w');
            ao.ui.UiUtility.horizontalBoxWithTwoCells(...
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