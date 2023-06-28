classdef MovingBarStatsView2 < handle 

    properties
        dataset
        xpts
        directions
        numROIs

        dataMap
        weights
        tempComp
        tempComp2
        dirComp
        reconstructions
        DSi

        currentRoi
        currentDir
        showReconstruction
        runningMax

        Figure
        TimeAxis
        MapAxis
        PolarAxis
        DirAxis
        TraceAxis
        Image

        RoiText
        UidText
        DsiText
    end

    methods
        function obj = MovingBarStatsView2(dataset)
            obj.dataset = dataset;

            obj.numROIs = obj.dataset.dataset.numROIs;
            obj.directions = obj.dataset.directions;
            obj.xpts = obj.dataset.xptsAvg;

            obj.currentRoi = 1;
            obj.currentDir = 1;
            obj.showReconstruction = false;

            obj.doAnalysis();
            obj.createUi();
        end
    end

    % Callbacks
    methods (Access = private)

        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentRoi == 1
                        return;
                    end
                    obj.currentRoi = obj.currentRoi - 1;
                    obj.updateView();
                case 'rightarrow'
                    obj.currentRoi = obj.currentRoi + 1;
                    obj.updateView();
                case 'downarrow'
                    if obj.currentDir == 1
                        return;
                    end
                    obj.currentDir = obj.currentDir - 1;
                    obj.updateTraces();
                case 'uparrow'
                    if obj.currentDir == numel(obj.directions)
                        return;
                    end
                    obj.currentDir = obj.currentDir + 1;
                    obj.updateTraces();
                case 'r'
                    if obj.showReconstruction 
                        obj.showReconstruction = false;
                    else
                        obj.showReconstruction = true;
                    end
                    obj.updateView();
                otherwise
                    return
            end
        end
    end

    % Figure display
    methods (Access = private)

        function updateView(obj)
            if obj.showReconstruction
                obj.Image.CData = obj.reconstructions(:,:,obj.currentRoi)';
            else
                obj.Image.CData = obj.dataMap(:,:,obj.currentRoi)';
            end
            obj.Image.CData = obj.Image.CData/max(abs(obj.Image.CData(:)));
            caxis(obj.MapAxis, [-1 1]);
            cla(obj.TimeAxis); hold(obj.TimeAxis, 'on');
            plot(obj.TimeAxis, obj.xpts, -obj.tempComp(:, obj.currentRoi),... 
                'k', 'LineWidth', 1);
            % plot(obj.TimeAxis, obj.xpts, -obj.tempComp2(:, obj.currentRoi),... 
            %     'b', 'LineWidth', 1);
            hold(obj.TimeAxis, 'off');
            plot(obj.DirAxis, flipud(obj.dirComp(:, obj.currentRoi)), flipud(obj.directions),... 
                'k', 'LineWidth', 1);

            
            polarplot(obj.PolarAxis, loop(deg2rad(obj.directions)), loop(obj.dirComp(:, obj.currentRoi)));
            
            obj.PolarAxis.ThetaTickLabels = [];
            obj.PolarAxis.RTickLabels = [];
            axis(obj.DirAxis, 'tight');
            axis(obj.TimeAxis, 'tight');

            if obj.DirAxis.YLim(1) > 0
                obj.DirAxis.YLim(1) = 0;
            elseif obj.DirAxis.YLim(2) < 0
                obj.DirAxis.YLim(2) = 0;
            end
            obj.runningMax = max(abs(obj.dataMap(:,:,obj.currentRoi)), [], "all");
                      
            obj.DsiText.Text = sprintf('DSi = %.2f', abs(obj.DSi(obj.currentRoi)));
            obj.RoiText.Text = num2str(obj.currentRoi);
            obj.UidText.Text = char(obj.dataset.dataset.roiUIDs.UID(obj.currentRoi));
            obj.updateTraces();
        end

        function updateTraces(obj)
            data = obj.dataset.getBarReps(obj.currentRoi, obj.directions(obj.currentDir), true);
            QI = qualityIndex(shiftdim(data', -1));
            if QI < 0.4
                iColor = [1 0.3 0.3];
            else
                iColor = [0.3 0.3 1];
            end
            cla(obj.TraceAxis);
            hold(obj.TraceAxis, 'on');
            for i = 1:size(data, 1)
                plot(obj.TraceAxis, obj.xpts, data(i,:), 'Color', lighten(iColor, 0.6));
            end
            xlim(obj.TraceAxis, [obj.xpts(1), obj.xpts(end)]);
            plot(obj.TraceAxis, obj.xpts, mean(data, 1), ...
                'Color', iColor, 'LineWidth', 1.5);

            if max(abs(data(:))) > obj.runningMax
                obj.runningMax = max(abs(data(:)));
            end
            ylim(obj.TraceAxis, [-obj.runningMax, obj.runningMax]);
            title(obj.TraceAxis, [num2str(obj.directions(obj.currentDir)), ' - ', sprintf('%.2f', QI)]);
        end
    end

    % Initialization
    methods (Access = private)
        function doAnalysis(obj)
            dsFun = exp(1i * deg2rad(obj.directions));

            M = obj.dataset.getBarAvgAll(1, true)';

            obj.tempComp = zeros(numel(obj.xpts), obj.numROIs);
            obj.dirComp = zeros(numel(obj.directions), obj.numROIs);
            obj.dataMap = zeros(size(M,1), size(M,2), obj.numROIs);
            obj.reconstructions = obj.dataMap;
            obj.weights = zeros(obj.numROIs,1);

            for j = 1:obj.numROIs 
                M = obj.dataset.getBarAvgAll(j, true)';
                [U, S, V] = svd(M);
                obj.tempComp(:,j) = S(2,2)*U(:,1);
                obj.tempComp2(:, j) = S(1,1)*U(:, 2);
                obj.dirComp(:,j) = V(:,1);
                obj.weights(j) = S(1,1);
                obj.reconstructions(:,:,j) = S(1,1) * U(:,1) * V(:,1)';
                obj.dataMap(:,:,j) = M;
                obj.DSi(j) = dsFun' * V(:,1);
            end
        end

        function createUi(obj)
            obj.Figure = uifigure(...
                'Name', 'MovingBarStatsView',...
                'DefaultUicontrolFontSize', 12,...
                'KeyPressFcn', @obj.onKeyPress);
            movegui(obj.Figure, 'center');
    
            mainGrid = uigridlayout(obj.Figure, [2 1]);
            blankBox = uilabel(mainGrid, 'Text', '');
            blankBox.Layout.Row = 1;
            blankBox.Layout.Column = 1;
            plotGrid = uigridlayout(mainGrid, [1 2]);
            plotGridA = uigridlayout(plotGrid, [2 2]);
            plotGridB = uigridlayout(plotGrid, [2 1]);

 
            % Plot grid A
            obj.TimeAxis = uiaxes(plotGridA);
            obj.MapAxis = uiaxes(plotGridA);
            obj.DirAxis = uiaxes(plotGridA);
            textGrid = uigridlayout(plotGridA, [3 1]);

            obj.Image = imagesc(obj.MapAxis, obj.dataMap(:,:,1),...
                'XData', obj.xpts, 'YData', obj.directions);
            axis(obj.MapAxis, 'tight');

            obj.TimeAxis.Layout.Row = 1;
            obj.TimeAxis.Layout.Column = 1;
            obj.MapAxis.Layout.Row = 2;
            obj.MapAxis.Layout.Column = 1;
            obj.DirAxis.Layout.Row = 2;
            obj.DirAxis.Layout.Column = 2;
            textGrid.Layout.Column = 2;
            textGrid.Layout.Row = 1;

            % Text grid
            obj.RoiText = uilabel(textGrid, 'Text', '1',...
                'HorizontalAlignment', 'center');
            obj.RoiText.Layout.Column = 1;
            obj.RoiText.Layout.Row = 1;

            obj.UidText = uilabel(textGrid, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.UidText.Layout.Column = 1;
            obj.UidText.Layout.Row = 2;

            obj.DsiText = uilabel(textGrid, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.DsiText.Layout.Column = 1;
            obj.DsiText.Layout.Row = 3;

            % Plot grid B
            obj.TraceAxis = uiaxes(plotGridB);
            obj.PolarAxis = polaraxes(plotGridB);
            obj.PolarAxis.ThetaTickLabels = [];
            obj.PolarAxis.RTickLabels = [];
            obj.PolarAxis.ThetaZeroLocation = 'right';
    
            obj.PolarAxis.Layout.Row = 1;
            obj.PolarAxis.Layout.Column = 1;
            obj.TraceAxis.Layout.Row = 2;
            obj.TraceAxis.Layout.Column = 1;


            mainGrid.RowHeight = {3, '1x'};
            plotGrid.ColumnWidth = {'2x', '1x'};
            plotGridA.ColumnWidth = {'3x', '1x'};
            plotGridA.RowHeight = {'1x', '3x'};
            plotGridB.RowHeight = {'1x','1x'};
            textGrid.RowHeight = {'fit', 'fit', 'fit'};
        end
    end
end