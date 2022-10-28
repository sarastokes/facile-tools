classdef TypeTableApp < handle 

    properties (Access = private)
        dataset
    end

    properties (SetAccess = private)
        Figure 
        Table 

        uidCountBox
    end

    methods
        function obj = TypeTableApp(dataset)
            obj.dataset = dataset;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onPush_Export(obj, ~, ~)
            newObject = obj.dataset;
            newObject.setTypeTable(obj.Table.Data);
            assignin('base', 'newObject', newObject);
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.Figure = uifigure('Name', 'Type Table App');

            layout = uigridlayout(obj.Figure, [2 1]);

            obj.Table = uitable(layout);
            obj.Table.Data = obj.dataset.typeTable;
            obj.Table.ColumnEditable = [false(1,2), true(1, size(obj.dataset.typeTable,2)-2)];
            obj.Table.Layout.Row = 1;
            obj.Table.Layout.Column = 1;

            uiLayout = uigridlayout(layout, [1 2]);
            uiLayout.Layout.Row = 2;
            uiLayout.Layout.Column = 1;
            obj.uidCountBox = uilabel(uiLayout,... 
                'Text', sprintf('%u UIDs', height(obj.Table.Data)),...
                'HorizontalAlignment', 'center');
            obj.uidCountBox.Layout.Row = 1;
            obj.uidCountBox.Layout.Column = 1;

            btn = uibutton(uiLayout,...
                'Text', 'Export',...
                'ButtonPushedFcn', @obj.onPush_Export);
            btn.Layout.Column = 2;
            btn.Layout.Row = 1;

            layout.RowHeight = {'1x', 'fit'};
            uiLayout.ColumnWidth = {'1x', 60};
            
        end
    end
end 