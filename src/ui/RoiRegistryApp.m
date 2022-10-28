classdef RoiRegistryApp < handle 

    properties (SetAccess = private)
        roiReg 
    end

    properties % (Access = private)
        figureHandle
        Table
    end

    methods
        function obj = RoiRegistryApp(roiRegistry)
            obj.roiReg = roiRegistry;
            obj.createUi();
        end
    end

    methods (Access = private)
        function onSearchRoi(obj, src, ~)
            searchedRoi = src.Value;
            whichCol = str2double(src.Tag);
            rowIdx = find(obj.Table.Data{:, whichCol} == searchedRoi);
            if ~isempty(rowIdx)
                scroll(obj.Table, 'row', rowIdx);
                obj.Table.Selection = [rowIdx, whichCol];
            end
        end

        function onSearchUid(obj, src, ~)
            assignin('base', 'src', src);
            rowIdx = find(obj.Table.Data{:, 1} == src.Value);
            
            if ~isempty(rowIdx)
                scroll(obj.Table, 'row', rowIdx);
                obj.Table.Selection = [rowIdx, 1];
            end
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = uifigure(...
                'Name', obj.roiReg.label(),...
                'Position', [0 0 400 400],...
                'DefaultUicontrolFontSize', 12);
            movegui(obj.figureHandle, 'center');
            drawnow;

            obj.Table = uitable(obj.figureHandle,...
                'Position', [10 10 350 355],...
                'ColumnEditable', true);
            obj.Table.Data = obj.roiReg.uidTable;
            obj.Table.Position(3) = 80 * size(obj.Table.Data, 2);
            obj.figureHandle.Position(3) = obj.Table.Position(3)+20;

            uieditfield(obj.figureHandle,...
                'Position', [10 370 80 20],...
                'ValueChangedFcn', @obj.onSearchUid);

            for i = 2:(size(obj.Table.Data, 2))
                uieditfield(obj.figureHandle, 'numeric',...
                    'Position', [(i-1)*85 370 75 20],...
                    'Tag', num2str(i),...
                    'ValueChangedFcn',@obj.onSearchRoi);
            end 
            
        end
    end
end 