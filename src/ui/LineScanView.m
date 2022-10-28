classdef LineScanView < handle

    properties
        imStack
        smoothStack

        currentLine
    end

    properties (SetAccess = private)
        figureHandle
        xtHandle
        xyAxes
        imHandle
        viewLine

        lineLabel
        normFlag
    end

    methods
        function obj = LineScanView(imStack)
            obj.imStack = imStack;
            obj.smoothStack = obj.imStack;
            for i = 1:size(obj.smoothStack,1)
                for j = 1:size(obj.smoothStack,2)
                    obj.smoothStack(i,j,:) = mysmooth(obj.imStack(i,j,:), 10);
                end
            end
            obj.currentLine = 1;
            obj.normFlag = false;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentLine == 1
                        return
                    end
                    obj.currentLine = obj.currentLine - 1;
                    obj.updateView();
                case 'rightarrow'
                    if obj.currentLine == size(obj.imStack,2)
                        return
                    end
                    obj.currentLine = obj.currentLine + 1;
                    obj.updateView()
                case 'n'
                    obj.normFlag = ~obj.normFlag;

            end
        end
    end

    methods (Access = private)
        function updateView(obj)
            if obj.normFlag
                obj.imHandle.CData = squeeze(obj.smoothStack(:,obj.currentLine,:));
            else
                obj.imHandle.CData = squeeze(obj.imStack(:,obj.currentLine,:));
            end
            obj.lineLabel.Text = sprintf('Line %u of %u',...
                obj.currentLine, size(obj.imStack,2));

            obj.viewLine.XData = [obj.currentLine, obj.currentLine];
        end

        function createUi(obj)
            obj.figureHandle = uifigure(...
                'KeyPressFcn', @obj.onKeyPress);
            movegui(obj.figureHandle, 'south');

            g = uigridlayout(obj.figureHandle, [2 2],...
                'RowHeight', {30, '1x'});

            obj.xyAxes = uiaxes(g);
            obj.xyAxes.Layout.Column = 1;
            obj.xyAxes.Layout.Row = [1 2];
            hold(obj.xyAxes, 'on');
            imagesc(mean(obj.imStack,3), 'Parent', obj.xyAxes);
            axis(obj.xyAxes, 'equal');
            axis(obj.xyAxes, 'tight');

            obj.viewLine = line(obj.xyAxes, [1 1], [1, size(obj.imStack,1)],...
                'LineWidth', 1, 'Color', 'r');

            obj.lineLabel = uilabel(g,...
                'HorizontalAlignment', 'center');
            obj.lineLabel.Layout.Column = 2;
            obj.lineLabel.Layout.Row = 1;

            obj.xtHandle = uiaxes(g);
            obj.xtHandle.Layout.Column = 2;
            obj.xtHandle.Layout.Row = 2;
            axis(obj.xtHandle, 'tight');
            axis(obj.xtHandle, 'off');

            obj.imHandle = imagesc(squeeze(obj.imStack(:,1,:)),...
                'Parent', obj.xtHandle);
        end
    end
end