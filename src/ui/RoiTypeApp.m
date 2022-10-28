classdef RoiTypeApp < handle

    properties (SetAccess = private)
        roiReg
    end

    properties (Access = private)
        Figure
        Table
        Stats
    end
    
    methods
        function obj = RoiTypeApp(roiRegistry)
            obj.roiReg = roiRegistry;
            obj.createUi();
        end
    end

    methods (Access = private)
        function onSearch_Uid(obj, src, ~)
            % ONSEARCH_UID
            rowIdx = find(obj.Table.Data{:, 1} == src.Value);
            
            if ~isempty(rowIdx)
                scroll(obj.Table, 'row', rowIdx);
                obj.Table.Selection = [rowIdx, 1];
            end
            src.Value = [];
        end

        function onPush_Export(obj, ~, ~)
            % ONPUSH_EXPORT
            assignin('base', 'roiReg', obj.roiReg);
            fprintf('Assigned as roiReg\n');
        end

        function onPush_Update(obj, ~, ~)
            % ONPUSH_UPDATE
            [G, groupNames] = findgroups(obj.Table.Data(:, 2));
            N = splitapply(@numel, G);
            obj.Stats.Data = table(groupNames, N, ...
                'VariableNames', {'Type', 'Count'});
        end
    end

    methods (Access = private)
        function createUi(obj)
            % CREATEUI
            obj.Figure = uifigure(...
                'Name', obj.roiReg.label(),...
                'Position', [0 0 400 450],...
                'DefaultUicontrolFontSize', 12);
            movegui(obj.Figure, 'center');

            obj.Table = uitable(obj.Figure,...
                'Position', [10 10 200 380],...
                'ColumnEditable', true);
            obj.Table.Data = obj.roiReg.typeTable;
            obj.Table.Position(3) = 80 * size(obj.Table.Data, 2);
            obj.Figure.Position(3) = obj.Table.Position(3)+170;

            obj.Stats = uitable(obj.Figure,...
                'Position', [obj.Table.Position(3)+10, 10, 150, 380],...
                'ColumnEditable', false);

            uibutton(obj.Figure,...
                'Position', [10, 410, 50, 25],...
                'Text', 'Export',...
                'ButtonPushedFcn', @obj.onPush_Export);
            uibutton(obj.Figure,...
                'Position', [70, 410, 50, 25],...
                'Text', 'Update',...
                'ButtonPushedFcn', @obj.onPush_Update);

            uieditfield(obj.Figure,...
                'Position', [10 370 80 20],...
                'ValueChangedFcn', @obj.onSearch_Uid);
        end
    end

end