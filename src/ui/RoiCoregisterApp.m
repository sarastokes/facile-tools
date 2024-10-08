classdef RoiCoregisterApp < handle
% ROICOREGISTERAPP
%
% See also:
%   RoiManagerApp, ImageComparisonApp
% -----------------------------------------------------------------------

    properties
        fixedDataset                % ao.core.Dataset
        movingDataset               % ao.core.Dataset

        tform                       % affine2d
        fixedXY          (:,2)      double
        movingXY         (:,2)      double

        registrationType (1,1)      string      = "nonreflectivesimilarity"
    end

    properties (Hidden, SetAccess = private)
        fixedUI                     % RoiManagerApp
        movingUI                    % RoiManagerApp
        flip1

        listeners                   event.listener

        figureHandle    (1,1)
        MovingMarker    (1,1)       matlab.graphics.primitive.Line
        FixedMarker     (1,1)       matlab.graphics.primitive.Line
        StatusBox       (1,1)       matlab.ui.control.Label
    end

    properties (Dependent)
        movingImage
        fixedImage
    end

    events
        SetNewUid
    end

    methods
        function obj = RoiCoregisterApp(fixedDataset, movingDataset, varargin)
            obj.fixedDataset = fixedDataset;
            obj.movingDataset = movingDataset;

            ip = inputParser();
            addParameter(ip, 'Flip1', false, @islogical);
            parse(ip, varargin{:});
            obj.flip1 = ip.Results.Flip1;

            obj.createUi();
            obj.getRoiCentroids();
            obj.bind();
        end

        function out = get.movingImage(obj)
            out = obj.movingUI.dsetImage;
        end

        function out = get.fixedImage(obj)
            out = obj.fixedUI.dsetImage;
        end

        function bind(obj)
            obj.listeners = [...
                addlistener(obj.fixedUI, 'SelectedRoi', @obj.onRoiClicked),...
                addlistener(obj.movingUI, 'SelectedRoi', @obj.onRoiClicked)];
        end
    end

    methods (Access = private)
        function registerImages(obj)
            % REGISTERIMAGES
            [xM, yM, xF, yF] = obj.getMatchedPoints();
            if strcmpi(obj.registrationType, 'polynomial')
                obj.tform = fitgeotrans([xF, yF], [xM, yM], 'polynomial', 3);
            else
                obj.tform = fitgeotrans([xF yF], [xM yM], obj.registrationType);
            end
            obj.StatusBox.Text = sprintf('Registered with %u ROIs', numel(xM));
        end

        function onMenu_ShowDisplacement(obj)
            if isempty(obj.tform)
                return
            end
            [X, Y] = meshgrid(1:5:size(obj.movingImage,1), 1:5:size(obj.movingImage,2));
            [xOffset, yOffset] = transformPointsForward(obj.tform, X, Y);
            
            axes('Parent', figure('Name', 'Displacement'));
            quiverC2D(Y(:), X(:), yOffset(:), xOffset(:));
            colormap(slanCM('thermal-2', 256));
            axis equal tight
            tightfig(gcf);
        end

        function checkOffsets(obj)
            [xM, yM, xF, yF] = obj.getMatchedPoints();
            roiDistances = zeros(1, numel(xM));
            for i = 1:numel(xM)
                roiDistances(i) = fastEuclid2d([xM(i) yM(i)], [xF(i), yF(i)]);
            end

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

            co = pmkmp(20, 'CubicL');
            maxDist = max(roiDistances) - min(roiDistances)+1;
            for i = 1:numel(xM)
                try
                    iColor = co(round(20*(roiDistances(i)-min(roiDistances)+1)/maxDist), :);
                catch
                    iColor = [0.2 0.2 0.5];
                end
                plot([xM(i) xF(i)], [yM(i) yF(i)], 'LineWidth', 0.8, 'Color', iColor);
            end
            set(ax, 'YDir', 'reverse');
            tightfig(ax.Parent);
            figPos(ax.Parent, 0.6, 1);
            drawnow;

            figure(); hold on;
            h = histogram(roiDistances, 'BinWidth', 0.5,...
                'FaceColor', hex2rgb('0044cd'), 'FaceAlpha', 0.5);
            h.BinLimits = [0 ceil(h.BinLimits(2))];
            title([obj.movingUI.datasetName ' to ' obj.fixedUI.datasetName],...
                'Interpreter', 'none');
            xlabel("Co-registered ROI Distance");
            ylabel("Number of ROIs")
            figPos(gcf, 0.8, 0.6);
            grid on
            xlabel("Distance between Coregistered ROIs");
            assignin('base','histHandle', h);
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
            residualError = zeros(size(x1));
            for i = 1:numel(x1)
                residualError(i) = fastEuclid2d([x1(i), y1(i)], [x2a(i), y2a(i)]);
            end
            title(ax, sprintf('Error = %.2f +- %.2f', ...
                mean(residualError), std(residualError)));
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
            try
                sameAsInput = affineOutputView(size(obj.movingImage),...
                     obj.tform, 'BoundsStyle','SameAsInput');
                imshowpair(obj.movingImage,...
                    imwarp(obj.fixedImage, obj.tform, "OutputView", sameAsInput));
            catch
                imshowpair(obj.movingImage,...
                    imwarp(obj.fixedImage, imref2d(size(obj.fixedImage)), obj.tform),...
                    'Scaling', 'independent', 'Parent', ax);
            end

            set(tformLayout, 'Widths', [-1 242 -1]);
            set(leftLayout, 'Heights', [-1 67]);
            set(mainLayout, 'Widths', [-1 -0.75]);
        end

        function autoReg(obj)
            numBlank = 0; numReg = 0; flaggedUIDs = [];
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
                if isempty(alignedUid) || alignedUid == ""
                    fprintf('Aligned %u to blank UID\n', i);
                    continue
                end
                if ismember(alignedUid, obj.movingUI.Table.Data{:,2})
                    flaggedUIDs = [flaggedUIDs; alignedUid]; %#ok<AGROW>
                    otherRoiID = obj.movingUI.Table.Data{obj.movingUI.Table.Data == alignedUid, 1};
                    refXY = obj.fixedXY(obj.fixedDataset.uid2roi(alignedUid),:);
                    D = fastEuclid2d(refXY, [obj.movingXY(i,:); obj.movingXY(otherRoiID, :)]);
                    if D(1) > D(2)
                        chosenROI = i;
                    else
                        chosenROI = otherRoiID;
                        obj.movingUI.Table.Data{i,2} = "";
                    end
                    % TODO: Check which has the smallest distance to UID
                    warning('Check on UID %s. Chose %u. Distances: %u=%.2f %u=%.2f\n',... 
                        alignedUid, i, chosenROI, D(1), otherRoiID, D(2));
                    if D(1) > 2
                        continue
                    end
                end

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
            if ~isempty(flaggedUIDs)
                fprintf('Flagged UIDs: '); disp(flaggedUIDs);
            end
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
            if round(x) > size(obj.movingUI.rois, 1) || round(x) < 1
                return
            elseif round(y) > size(obj.movingUI.rois, 2) || round(y) < 1
                return
            else
                roiID = obj.movingUI.rois(round(x), round(y));
            end
        end

        function roiID = findFixedPoints(obj, x, y)
            roiID = 0;
            if round(x) > size(obj.fixedUI.rois,1) || round(x) < 1
                return
            elseif round(y) > size(obj.fixedUI.rois,2) || round(y) < 1
                return
            else
                roiID = obj.fixedUI.rois(round(x), round(y));
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

        function onMenu_ChangeRegistrationType(obj, src, ~)
            obj.registrationType = string(src.Text);
            set(findall(obj.figureHandle, "Tag", "RegType"), "Checked", false);
            src.Checked = true;
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

        function onMenu_CompareImages(obj, ~, ~)
            if isempty(obj.tform)
                return
            end
            outputView = affineOutputView(...
                size(obj.fixedImage), obj.tform,...
                "BoundsStyle", "sameAsInput");
            ImageComparisonApp(...
                imadjust(obj.movingImage), ...
                imadjust(imwarp(obj.fixedImage, obj.tform, ...
                    'OutputView', outputView)));
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
            S = regionprops(obj.fixedUI.rois, 'Centroid');
            obj.fixedXY = cat(1, S.Centroid);
            S = regionprops(obj.movingUI.rois, 'Centroid');
            obj.movingXY = cat(1, S.Centroid);
        end

        function createUi(obj)
            obj.figureHandle = uifigure(...
                'DefaultUicontrolFontSize', 12,...
                'DefaultUicontrolFontName', get(0, 'DefaultUicontrolFontName'),...
                'KeyPressFcn', @obj.onKeyPress);

            obj.figureHandle.Position(3) = obj.figureHandle.Position(3) * 1.65;
            obj.figureHandle.Position(4) = obj.figureHandle.Position(4) + 100;
            %movegui(obj.figureHandle, 'center');

            mainLayout = uigridlayout(obj.figureHandle, [2 2],...
                'RowHeight', {20, '1x'});
            obj.StatusBox = uilabel(mainLayout, 'Text', '',...
                'HorizontalAlignment', 'center');
            obj.StatusBox.Layout.Row = 1;
            obj.StatusBox.Layout.Column = [1 2];

            obj.fixedUI = RoiManagerApp(obj.fixedDataset, mainLayout, obj.flip1);
            obj.fixedUI.setTag('fixed');
            obj.fixedUI.Layout.Layout.Row = 2;
            obj.fixedUI.Layout.Layout.Column = 1;

            obj.movingUI = RoiManagerApp(obj.movingDataset, mainLayout);
            obj.movingUI.setTag('moving');
            obj.movingUI.Layout.Layout.Row = 2;
            obj.movingUI.Layout.Layout.Column = 2;

            set(obj.figureHandle, 'Name',...
                [obj.movingUI.datasetName ' to ' obj.fixedUI.datasetName]);

            % Registration menu
            hMenu = uimenu(obj.figureHandle, 'Text', 'Registration');
            mItem = uimenu(hMenu,'Text','&Register ROIs');
            mItem.Accelerator = 'R';
            mItem.MenuSelectedFcn = @obj.onMenu_RegisterImages;
            
            sMenu = uimenu(hMenu, "Text", "Registration Type");
            mItem = uimenu(sMenu,"Text", "Affine", "Tag", "RegType");
            mItem.MenuSelectedFcn = @obj.onMenu_ChangeRegistrationType;
            mItem = uimenu(sMenu, "Text", "NonreflectiveSimilarity",...
                "Checked", "on", "Tag", "RegType");
            mItem.MenuSelectedFcn = @obj.onMenu_ChangeRegistrationType;
            mItem = uimenu(sMenu, "Text", "projective", "Tag", "RegType");
            mItem.MenuSelectedFcn = @obj.onMenu_ChangeRegistrationType;
            mItem = uimenu(sMenu, "Text", "Polynomial", "Tag", "RegType");
            mItem.MenuSelectedFcn = @obj.onMenu_ChangeRegistrationType;


            mItem = uimenu(hMenu, 'Text', 'Auto Register');
            mItem.Accelerator = 'A';
            mItem.MenuSelectedFcn = @obj.onMenu_AutoRegister;

            mItem = uimenu(hMenu, 'Text', 'List Coregistered');
            mItem.MenuSelectedFcn = @obj.onMenu_ListCoregistered;

            % Visualization menu
            hMenu = uimenu(obj.figureHandle, "Text", "Visualization");

            mItem = uimenu(hMenu, 'Text', '&Check Registration');
            mItem.Accelerator = 'C';
            mItem.MenuSelectedFcn = @obj.onMenu_CheckTransform;

            mItem = uimenu(hMenu, 'Text', 'Check Offsets');
            mItem.Accelerator = 'O';
            mItem.MenuSelectedFcn = @obj.onMenu_CheckOffsets;

            mItem = uimenu(hMenu, 'Text', 'Compare Registered Images');
            mItem.MenuSelectedFcn = @obj.onMenu_CompareImages;

            mItem = uimenu(hMenu,  'Text', 'Show displacement');
            mItem.MenuSelectedFcn = @obj.onMenu_ShowDisplacement;

            mItem = uimenu(hMenu, 'Text', 'Color Coregistered');
            mItem.Accelerator = 'X';
            mItem.MenuSelectedFcn = @obj.onMenu_ColorCoregistered;
            

            % Create target marker
            obj.MovingMarker = line(obj.movingUI.Axes, NaN, NaN,...
                'Marker', 'x', 'Color', 'r', 'LineStyle', 'None',...
                'LineWidth', 1.5, 'MarkerSize', 10);
            obj.FixedMarker = line(obj.fixedUI.Axes, NaN, NaN,...
                'Marker', 'x', 'Color', 'r', 'LineStyle', 'None',...
                'LineWidth', 1.5, 'MarkerSize', 10);
        end
    end
end