classdef RoiCoregisterApp < handle

    properties
        fixedDataset            % ao.core.Dataset
        movingDataset           % ao.core.Dataset

        tform                   % affine2d
        fixedXY(:,2)            double
        movingXY(:,2)           double

        fixedUI                 % RoiManagerApp2
        movingUI                % RoiManagerApp2
        listeners

        autoMode(1,1)           logical                         = false

        Figure(1,1)             %matlab.ui.Figure
        MovingMarker(1,1)       matlab.graphics.primitive.Line
        FixedMarker(1,1)        matlab.graphics.primitive.Line
        StatusBox
    end

    events
        SetNewUid
    end

    methods
        function obj = RoiCoregisterApp(fixedDataset, movingDataset)
            obj.fixedDataset = fixedDataset;
            obj.movingDataset = movingDataset;

            obj.createUi();
            obj.getRoiCentroids();
            obj.bind();
        end

        function bind(obj)
            obj.listeners = [...
                addlistener(obj.fixedUI, 'SelectedRoi', @obj.onRoiClicked),...
                addlistener(obj.movingUI, 'SelectedRoi', @obj.onRoiClicked)];
            % obj.movingUI.setListener(obj, 'SetNewUid');
        end
    end

    methods (Access = private)
        function registerImages(obj)
            % REGISTERIMAGES
            [xM, yM, xF, yF] = obj.getMatchedPoints();
            obj.tform = fitgeotrans([xF yF], [xM yM], 'nonreflectivesimilarity');
            obj.StatusBox.Text = sprintf('Registered with %u ROIs', numel(xM));
        end

        function checkOffsets(obj)
            [xM, yM, xF, yF] = obj.getMatchedPoints();
            roiDistances = zeros(1, numel(xM));
            for i = 1:numel(xM)
                roiDistances(i) = fastEuclid2d([xM(i) yM(i)], [xF(i), yF(i)]);
            end
            assignin('base', 'roiDistances', roiDistances);

            ax = axes('Parent', figure('Name', 'Offsets'));
            hold(ax, 'on');
            plot(xM, yM, 'ok', 'MarkerSize', 4, 'LineStyle', 'none');
            plot(ax, xF, yF, 'o', 'Color', [0.5 0.5 0.5],...
                'MarkerSize', 4, 'LineStyle', 'none');
            axis(ax, 'equal');
            axis(ax, 'tight');
            set(ax, 'Box', 'on', 'XTickLabel', [], 'YTickLabel', []);
            grid(ax, 'on');
            ax.YLim(1) = 0; ax.XLim(1) = 0;

            co = pmkmp(10, 'CubicL');
            maxDist = max(roiDistances);
            for i = 1:numel(xM)
                try
                    iColor = co(10*round(roiDistances(i)/maxDist), :);
                catch
                    iColor = [0.2 0.2 0.5];
                end
                plot([xM(i) xF(i)], [yM(i) yF(i)], 'LineWidth', 0.8, 'Color', iColor);
            end
            set(ax, 'YDir', 'reverse');
            tightfig(ax.Parent);
            figPos(ax.Parent, 0.6, 1);
            drawnow;
        end

        function checkTransform(obj)
            if isempty(obj.tform)
                return 
            end

            [x1, y1, x2, y2] = obj.getMatchedPoints();
            [x2a, y2a] = transformPointsForward(obj.tform, x2, y2);

            fh = figure();
            mainLayout = uix.HBox('Parent', fh);
            leftLayout = uix.VBox('Parent', mainLayout);

            % Show point offsets
            ax = axes(uipanel('Parent', leftLayout)); hold(ax, 'on');
            plot(ax, x1, y1, 'ob', 'LineStyle', 'none', 'DisplayName', 'Moving');
            plot(ax, x2a, y2a, 'xr', 'LineStyle', 'none', 'Display', 'FixedT');
            title(ax, 'o = Moving, x = FixedT', ...
                'FontSize', 10, 'FontWeight', 'normal');
            grid(ax, 'on');
            axis(ax, 'equal');
            axis(ax, 'tight');
            set(ax, 'YDir', 'reverse');
            ax.YLim(1) = 0; ax.XLim(1) = 0;
            hideAxisLabels(ax);

            % Show transform
            tformLayout = uix.HBox('Parent', leftLayout);
            uix.Empty('Parent', tformLayout);
            uitable(tformLayout, ...
                'Data', round(obj.tform.T, 4),...
                'ColumnName', [], 'RowName', [],...
                'ColumnEditable', false,...
                'ColumnWidth', {80 80 80},... 
                'FontSize', 10, 'RowStriping', 'off');
            uix.Empty('Parent', tformLayout);

            % Compare images
            ax = axes('Parent', uipanel('Parent', mainLayout));
            sameAsInput = affineOutputView(size(obj.movingDataset.avgImage), obj.tform,... 
                'BoundsStyle','SameAsInput');
            imshowpair(obj.movingDataset.avgImage,...
                imwarp(obj.fixedDataset.avgImage, obj.tform, 'OutputView', sameAsInput),... 
                'Scaling', 'independent', 'Parent', ax);

            set(tformLayout, 'Widths', [-1 242 -1]);
            set(leftLayout, 'Heights', [-1 67]);
            set(mainLayout, 'Widths', [-1 -0.75]);

        end
    
        function autoReg(obj)
            numBlank = 0; numReg = 0;
            for i = 1:height(obj.movingUI.Table.DisplayData)
                if obj.movingUI.Table.DisplayData{i,2} ~= ""
                    continue
                end
                numBlank = numBlank + 1;
                [x, y] = transformPointsInverse(obj.tform,...
                    obj.movingXY(i,1), obj.movingXY(i,2));
                alignedRoi = obj.findFixedPoints(y, x);
                if alignedRoi == 0
                    continue
                end
                numReg = numReg + 1;
                alignedUid = obj.fixedDataset.roi2uid(alignedRoi);

                obj.StatusBox.Text = sprintf('ROI estimate = %u, %s\n',...
                    alignedRoi, alignedUid);
                obj.movingUI.Table.Data{i,2} = alignedUid;
                scroll(obj.movingUI.Table, 'row', i);
                fprintf('Aligned %u to %s\n', i, alignedUid);
                obj.movingUI.updateRoiCounts();
                obj.movingUI.updateRoiCircles(i, alignedUid);
                drawnow;
                pause(0.1);
            end
            fprintf('RoiCoregisterApp: %u blank, %u registered\n',...
                numBlank, numReg);
        end
    end

    % Helper functions
    methods (Access = private)
        function [movingIDs, fixedIDs] = matchUIDs(obj)
            [~, b] = ismember(obj.movingUI.Table.DisplayData{:,2},...
                obj.fixedUI.Table.DisplayData{:,2}, 'rows');
            % b shows for each element in movingUI, the matched element in
            % fixedUI, if it exists. If not, 0
            fixedIDs = []; movingIDs = [];
            for i = 1:height(b)
                if b(i) ~= 0 && obj.fixedUI.Table.DisplayData{b(i),2} ~= ""
                    fixedIDs = cat(1, fixedIDs, b(i));
                    movingIDs = cat(1, movingIDs, i);
                end
            end
        end

        function [xM, yM, xF, yF] = getMatchedPoints(obj)
            [movingIDs, fixedIDs] = obj.matchUIDs();
            xM = obj.movingXY(movingIDs, 1);
            xF = obj.fixedXY(fixedIDs, 1);

            yM = obj.movingXY(movingIDs, 2);
            yF = obj.fixedXY(fixedIDs, 2);
        end

        function roiID = findMovingPoints(obj, x, y)
            roiID = 0;
            if round(x) > size(obj.movingDataset.rois,1) || round(x) < 1
                return
            elseif round(y) > size(obj.movingDataset.rois,2) || round(y) < 1
                return
            else
                roiID = obj.movingDataset.rois(round(x), round(y));
            end
        end

        function roiID = findFixedPoints(obj, x, y)
            roiID = 0;
            if round(x) > size(obj.fixedDataset.rois,1) || round(x) < 1
                return
            elseif round(y) > size(obj.fixedDataset.rois,2) || round(y) < 1
                return
            else
                roiID = obj.fixedDataset.rois(round(x), round(y));
            end
        end
    
        function [x2, y2] = transformMovingToFixed(obj, x, y)
            if nargin < 3 && numel(x) == 2
                y = x(2);
                x = x(1);
            end
            [x2, y2] = transformPointsInverse(obj.tform, x, y);
        end
    end

    % Callbacks
    methods (Access = private)
        function onRoiClicked(obj, src, evt)
            clickedRoi = evt.Source.currentRoi;
            if isempty(obj.tform)
                return
            end
            if strcmp(src.Tag, 'fixed')
                [x, y] = transformPointsForward(obj.tform,...
                    obj.fixedXY(clickedRoi,1), obj.fixedXY(clickedRoi,2));
                set(obj.MovingMarker, 'XData', x, 'YData', y, 'Visible', 'on');
                alignedRoi = obj.findMovingPoints(y, x);
                if alignedRoi == 0
                    obj.StatusBox.Text = sprintf('No ROI found at location %.2f %.2f!\n', x, y);
                    obj.MovingMarker.Color = rgb('magenta');
                else
                    obj.StatusBox.Text = sprintf('ROI estimate = %u, %s\n',...
                        alignedRoi, obj.movingDataset.roi2uid(alignedRoi));
                    obj.movingUI.Table.Selection = [alignedRoi, 2];
                    scroll(obj.movingUI.Table, 'row', alignedRoi);
                    obj.MovingMarker.Color = 'g';
                end
            elseif strcmp(src.Tag, 'moving')
                [x, y] = transformPointsInverse(obj.tform,...
                    obj.movingXY(clickedRoi,1), obj.movingXY(clickedRoi,2));
                set(obj.FixedMarker, 'XData', x, 'YData', y, 'Visible', 'on');
                set(obj.MovingMarker, 'Visible', 'off');
                alignedRoi = obj.findFixedPoints(y, x);
                if alignedRoi == 0
                    obj.StatusBox.Text = sprintf('No ROI found at location %.2f %.2f!\n', x, y);
                    obj.FixedMarker.Color = rgb('magenta');
                else
                    obj.StatusBox.Text = sprintf('ROI estimate = %u, %s\n',...
                        alignedRoi, obj.fixedDataset.roi2uid(alignedRoi));
                    obj.fixedUI.Table.Selection = [alignedRoi, 2];
                    scroll(obj.fixedUI.Table, 'row', alignedRoi);
                    obj.FixedMarker.Color = 'g';
                end
            end
        end

        function onKeyPress(obj, ~, evt)
            switch evt.Character
                case 'h'
                    obj.MovingMarker.Visible = 'off';
                    obj.FixedMarker.Visible = 'off';
                case 'x'
                    set(obj.MovingMarker, 'XData', NaN, 'YData', NaN,...
                        'Visible', 'off');
                    set(obj.FixedMarker, 'XData', NaN, 'YData', NaN,...
                        'Visible', 'off');
            end
        end

        function onMenu_CheckOffsets(obj, ~, ~)
            obj.checkOffsets();
        end

        function onMenu_RegisterImages(obj, ~, ~)
            obj.registerImages();
            obj.checkTransform();
        end

        function onMenu_CheckTransform(obj, ~, ~)
            obj.checkTransform();
        end

        function onMenu_AutoRegister(obj, ~, ~)
            if isempty(obj.tform)
                return
            end
            obj.autoReg();
        end

        function onMenu_ListCoregistered(obj, ~, ~)
            idx = ismember(obj.fixedUI.Table.DisplayData{:,2},...
                obj.movingUI.Table.DisplayData{:,2});
            uids = obj.fixedUI.Table.DisplayData{idx,2};
            uids = sort(uids);
            fprintf('Fixed UIDs present in Moving dataset:\n');
            for i = 1:numel(uids)
                fprintf('%s\n', uids(i));
            end
        end

        function onMenu_ColorCoregistered(obj, ~, ~)
            obj.StatusBox.Text = 'Coloring coregistered rois...'; drawnow;
            [movingIDs, fixedIDs] = obj.matchUIDs();

            for i = 1:numel(movingIDs)
                h = findobj(obj.movingUI.roiHandles,... 
                    'Tag', ['roi', num2str(movingIDs(i))]);
                h.Color = rgb('lavender');
                drawnow;
            end
            for i = 1:numel(fixedIDs)
                h = findobj(obj.fixedUI.roiHandles,... 
                    'Tag', ['roi', num2str(fixedIDs(i))]);
                h.Color = rgb('lavender');
                drawnow;
            end
            obj.StatusBox.Text = ''; drawnow;
        end
    end

    % Initialization methods
    methods (Access = private)
        function getRoiCentroids(obj)
            S = regionprops(obj.fixedDataset.rois, 'Centroid');
            obj.fixedXY = cat(1, S.Centroid);
            S = regionprops(obj.movingDataset.rois, 'Centroid');
            obj.movingXY = cat(1, S.Centroid);
        end

        function createUi(obj)
            obj.Figure = uifigure(...
                'Name', [obj.movingDataset.getLabel() ' to ' obj.fixedDataset.getLabel()],...
                'DefaultUicontrolFontSize', 12,...
                'KeyPressFcn', @obj.onKeyPress);
                       
            obj.Figure.Position(3) = obj.Figure.Position(3) * 1.65;
            obj.Figure.Position(4) = obj.Figure.Position(4) + 100;
            movegui(obj.Figure, 'center');

            mainLayout = uigridlayout(obj.Figure, [2 2],...
                'RowHeight', {20, '1x'});
            obj.StatusBox = uilabel(mainLayout, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.StatusBox.Layout.Row = 1;
            obj.StatusBox.Layout.Column = [1 2];

            obj.fixedUI = RoiManagerApp2(obj.fixedDataset, mainLayout);
            obj.fixedUI.setTag('fixed');
            obj.fixedUI.Layout.Layout.Row = 2;
            obj.fixedUI.Layout.Layout.Column = 1;

            obj.movingUI = RoiManagerApp2(obj.movingDataset, mainLayout);
            obj.movingUI.setTag('moving');
            obj.movingUI.Layout.Layout.Row = 2;
            obj.movingUI.Layout.Layout.Column = 2;

            hMenu = uimenu(obj.Figure, 'Text', 'Registration');
            mItem = uimenu(hMenu, 'Text', 'Check Offsets');
            mItem.Accelerator = 'O';
            mItem.MenuSelectedFcn = @obj.onMenu_CheckOffsets;

            mItem = uimenu(hMenu,'Text','&Register ROIs');
            mItem.Accelerator = 'R';
            mItem.MenuSelectedFcn = @obj.onMenu_RegisterImages;

            mItem = uimenu(hMenu, 'Text', '&Check Registration');
            mItem.Accelerator = 'C';
            mItem.MenuSelectedFcn = @obj.onMenu_CheckTransform;

            mItem = uimenu(hMenu, 'Text', 'Auto Register');
            mItem.Accelerator = 'A';
            mItem.MenuSelectedFcn = @obj.onMenu_AutoRegister;

            mItem = uimenu(hMenu, 'Text', 'Color Coregistered');
            mItem.Accelerator = 'X';
            mItem.MenuSelectedFcn = @obj.onMenu_ColorCoregistered;

            mItem = uimenu(hMenu, 'Text', 'List Coregistered');
            mItem.Accelerator = 'L';
            mItem.MenuSelectedFcn = @obj.onMenu_ListCoregistered;

            % Create target marker
            obj.MovingMarker = line(obj.movingUI.Axes, NaN, NaN,...
                'Marker', 'x', 'Color', 'r', 'LineStyle', 'None');
            obj.FixedMarker = line(obj.fixedUI.Axes, NaN, NaN,...
                'Marker', 'x', 'Color', 'r', 'LineStyle', 'None');
        end
    end
end