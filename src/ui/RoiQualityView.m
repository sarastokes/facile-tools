classdef RoiQualityView < handle

    properties 
        Dataset
        imStack
        roiList 
        bounds
        X
        Y
        T 

        data

        figureHandle
    end

    methods 
        function obj = RoiQualityView(Dataset, imStack)
            obj.Dataset = Dataset;
            obj.imStack = imStack;

            obj.roiList = unique(Dataset.rois(:));
            obj.roiList(1) = [];

            [obj.X, obj.Y, obj.T] = size(obj.imStack);

            obj.data = struct();
            S = regionprops('table', Dataset.rois, 'BoundingBox');
            obj.bounds = S.BoundingBox;
            % for i = 1:Dataset.numROIs
            %     obj.data(i).bounds = S.BoundingBox(i, :);
            % end

            obj.createUi();
        end
    end

    methods (Access = private)
        function changeRoi(obj)

        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentRoi == 1
                        return
                    else
                        obj.currentRoi = obj.currentRoi - 1;
                    end
                case 'rightarrow'
                    if obj.currentRoi == obj.EG.numROIs
                        return
                    else
                        obj.currentRoi = obj.currentRoi + 1;
                    end
                otherwise
                    return
            end

            obj.changeRoi();
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle(...
                'Name', 'RoiQualityApp',...
                'Color', 'w',...
                'NumberTitle', 'off',...
                'Toolbar', 'none',...
                'Menubar', 'none',...
                'DefaultUicontrolBackgroundColor', 'w',...
                'DefaultUicontrolFontSize', 12,...
                'KeyPressFcn', @obj.onKeyPress);
            
            mainLayout = uix.HBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            uiLayout = uix.VBox('Parent', mainLayout,...
                'BackgroundColor', 'w');
            axLayout = uipanel('Parent', mainLayout,...
                'BackgroundColor', 'w');
            set(mainLayout, 'Widths', [-1, -3]);
        end
    end
end
