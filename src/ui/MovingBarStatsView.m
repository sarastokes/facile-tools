classdef MovingBarStatsView < handle

    properties (SetAccess = private)
        dataset 
        numROIs 
        directions 
        xpts 

        dsFun 
        DSi
        tempComp
        dirComp
        weights 
        dataMap
        reconstructions
    end

    properties% (Access = private)
        currentRoi
        currentDir
        showReconstruction

        figureHandle
        mapAxis
        mapHandle
        directionAxis
        temporalAxis
        traceAxis
        polarAxis
    end

    methods
        function obj = MovingBarStatsView(dataset)
            if isa(dataset, 'ao.core.Dataset')
                obj.dataset = MovingBarDataset(dataset);
            elseif isa(dataset, 'MovingBarDataset')
                obj.dataset = dataset;
            end

            obj.numROIs = obj.dataset.dataset.numROIs;
            obj.directions = obj.dataset.directions;
            obj.xpts = obj.dataset.xptsAvg;

            % Set up analysis functions
            obj.dsFun = exp(1i * deg2rad(obj.directions));

            obj.currentRoi = 1;
            obj.currentDir = 1;
            obj.showReconstruction = false;

            obj.analyzeData();
            obj.createUi();
        end
    end

    methods (Access = private)
        function updateView(obj)
            if obj.showReconstruction
                obj.mapHandle.CData = obj.reconstructions(:,:,obj.currentRoi)';
            else
                obj.mapHandle.CData = obj.dataMap(:,:,obj.currentRoi)';
            end
            obj.mapHandle.CData = obj.mapHandle.CData/max(abs(obj.mapHandle.CData(:)));
            caxis(obj.mapAxis, [-1 1]);
            plot(obj.temporalAxis, obj.xpts, obj.tempComp(:, obj.currentRoi),... 
                'k', 'LineWidth', 1);
            plot(obj.directionAxis, flipud(obj.dirComp(:, obj.currentRoi)), flipud(obj.directions),... 
                'k', 'LineWidth', 1);
            
            polarplot(obj.polarAxis, loop(obj.directions), loop(obj.dirComp(:, obj.currentRoi)));
            axis(obj.directionAxis, 'tight');
            axis(obj.temporalAxis, 'tight');

            if obj.directionAxis.YLim(1) > 0
                obj.directionAxis.YLim(1) = 0;
            elseif obj.directionAxis.YLim(2) < 0
                obj.directionAxis.YLim(2) = 0;
            end
            set(findByTag(obj.figureHandle, 'DSi'),...           
                'String', sprintf('DSi = %.2f', abs(obj.DSi(obj.currentRoi))));
            set(findByTag(obj.figureHandle, 'CurrentROI'),...
                'String', [num2str(obj.currentRoi)]);
            set(findByTag(obj.figureHandle, 'CurrentUid'),...
                'String', char(obj.dataset.dataset.roiUIDs.UID(obj.currentRoi)));
            obj.updateTraces();
        end

        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    obj.currentRoi = obj.currentRoi - 1;
                case 'rightarrow'
                    obj.currentRoi = obj.currentRoi + 1;
                case 'downarrow'
                    if obj.currentDir == 1
                        return;
                    end
                    obj.currentDir = obj.currentDir - 1;
                case 'uparrow'
                    if obj.currentDir == numel(obj.directions)
                        return;
                    end
                    obj.currentDir = obj.currentDir + 1;
                case 'r'
                    if obj.showReconstruction 
                        obj.showReconstruction = false;
                    else
                        obj.showReconstruction = true;
                    end
                otherwise
                    return
            end
            obj.updateView();
        end

        function updateTraces(obj)
            data = obj.dataset.getBarReps(obj.currentRoi, obj.directions(obj.currentDir), true);
            cla(obj.traceAxis);
            hold(obj.traceAxis, 'on');
            for i = 1:size(data, 1)
                plot(obj.xpts, data(i,:), 'Color', [0.7 0.7 1]);
            end
            plot(obj.xpts, mean(data, 1), 'Color', [0.4 0.4 1], 'LineWidth', 1.5);
            title(obj.traceAxis, num2str(obj.currentDir));
        end

    end

    methods (Access = private)

        function analyzeData(obj)
            M = obj.dataset.getBarAvgAll(1)';

            obj.tempComp = zeros(numel(obj.xpts), obj.numROIs);
            obj.dirComp = zeros(numel(obj.directions), obj.numROIs);
            obj.dataMap = zeros(size(M,1), size(M,2), obj.numROIs);
            obj.reconstructions = obj.dataMap;
            obj.weights = zeros(obj.numROIs,1);

            for j = 1:obj.numROIs 
                M = obj.dataset.getBarAvgAll(j, true)';
                [U, S, V] = svd(M);
                obj.tempComp(:,j) = U(:,1);
                obj.dirComp(:,j) = V(:,1);
                obj.weights(j) = S(1,1);
                obj.reconstructions(:,:,j) = S(1,1) * U(:,1) * V(:,1)';
                obj.dataMap(:,:,j) = M;
                obj.DSi(j) = obj.dsFun' * V(:,1);
            end
        end

        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'MovingBarView',...
                'DefaultUicontrolFontSize', 12,...
                'KeyPressFcn', @obj.onKeyPress);
            
            mainLayout = uix.VBox('Parent', obj.figureHandle);
            textLayout = uix.HBox('Parent', mainLayout);
            uicontrol(textLayout, 'Style', 'text',...
                'String', num2str(obj.currentRoi),...
                'Tag', 'CurrentROI');
            uicontrol(textLayout, 'Style', 'text',...
                'String', char(obj.dataset.dataset.roiUIDs.UID(obj.currentRoi)),...
                'Tag', 'CurrentUid');
            uicontrol(textLayout, 'Style', 'text',...
                'String', sprintf('DSi = %.2f', obj.DSi(1)),...
                'Tag', 'DSi');

            plotLayout = uix.HBox('Parent', mainLayout);
            p = axes('Parent', uipanel('Parent', plotLayout));
            set(mainLayout, 'Heights', [20, -1]);
            obj.temporalAxis = subplot(4, 4, 1:3, p);
            obj.directionAxis = subplot(4, 4, [8 12 16]);
            obj.mapAxis = subplot(4, 4, [5:7, 9:11, 13:15]);
            obj.mapHandle = imagesc(squeeze(obj.dataMap(:,:,1)),...
                'XData', obj.xpts, 'YData', obj.directions,...
                'Parent', obj.mapAxis);
            set(obj.mapAxis, 'YDir', 'reverse');
            axis(obj.mapAxis, 'tight');
            ylabel(obj.mapAxis, 'Direction');
            xlabel(obj.mapAxis, 'Time');
            caxis(obj.mapAxis, [-1 1]);
            colormap(obj.mapAxis, pmkmp(256, 'Cubicl'));

            obj.polarAxis = subplot(4,4,4,polaraxes);
            polarplot(obj.polarAxis, loop(obj.directions), loop(obj.dirComp(:, obj.currentRoi)));
            obj.polarAxis.RTickLabels = [];
            obj.polarAxis.ThetaTickLabels = [];

            obj.traceAxis = axes('Parent', uipanel('Parent', plotLayout));
            set(plotLayout, 'Widths', [-2.5 -1]);

            obj.updateView();
            obj.updateTraces();
        end
    end
end 