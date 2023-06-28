classdef DualOnsetOffsetChart < matlab.ui.componentcontainer.ComponentContainer

    properties (Dependent)
        XData(:,1) double {mustBeReal}
        Roi 
        TData1
        TData2
    end

    properties (Access = private)
        XData_ = double.empty(0,1)
        Roi_ = 1
        DataUpdateRequired = false()
        TData1_
        TData2_
    end

    properties (Access = private, Transient, NonCopyable)
        Axes(1,2) % matlab.graphics.axis.Axes
        GridLayout matlab.ui.container.GridLayout
        RoiLabel matlab.ui.control.Label
    end

    properties (Constant, Hidden)
        Dependencies = "MATLAB"
    end

    methods
        function value = get.XData(obj)
            value = obj.XData_;
        end

        function set.XData(obj, value)
            obj.XData_ = value;
        end

        function value = get.TData1(obj)
            value = obj.TData1_;
        end

        function set.TData1(obj, value)
            obj.TData1_ = value;
        end

        function value = get.TData2(obj)
            value = obj.TData2_;
        end

        function set.TData2(obj, value)
            obj.TData2_ = value;
        end

        function value = get.Roi(obj)
            value = obj.Roi_;
        end

        function set.Roi(obj, value)
            obj.Roi_ = value;
        end
    end

    methods (Access = protected)
        function setup(obj)
            obj.GridLayout = uigridlayout(...
                obj, [1 2],...
                'RowHeight', {30, "1x"}, 'ColumnWidth', ["1x", "1x"]);
            obj.RoiLabel = uilabel(obj.GridLayout,...
                'Text', 'Roi 1');
            obj.RoiLabel.Layout.Row = 1;
            obj.RoiLabel.Layout.Column = [1 2];
            
            obj.Axes(1) = OnsetOffsetChart('Parent', obj.GridLayout);
            %obj.Axes(1) = OnsetOffsetChart('XData', obj.XData,...
            %    'OnsetData', obj.TData1(obj.Roi,:),...
            %    'OffsetData', obj.TData1(obj.Roi,:),...
            %    'RatioData', obj.TData1(obj.Roi,:),...
            %    'Parent', obj.GridLayout);
            obj.Axes(1).Layout.Row = 2;
            obj.Axes(1).Layout.Column = 1;
            
            
            obj.Axes(2) = OnsetOffsetChart('Parent', obj.GridLayout);
            % obj.Axes(2) = OnsetOffsetChart('XData', obj.XData,...
            %     'OnsetData', obj.TData2(obj.Roi,:),...
            %     'OffsetData', obj.TData2(obj.Roi,:),...
            %     'RatioData', obj.TData2(obj.Roi,:),...
            %     'Parent', obj.GridLayout);
            obj.Axes(2).Layout.Row = 2;
            obj.Axes(2).Layout.Column = 2;

            set(ancestor(obj, "figure"), "KeyPressFcn", @obj.onKeyPress);
        end

        function update(obj)
            if ~obj.DataUpdateRequired
                return
            end

            set(obj.Axes(1), 'XData', obj.XData,...
                'OnsetData', obj.TData1(obj.Roi,:),...
                'OffsetData', obj.TData1(obj.Roi,:),...
                'RatioData', obj.TData1(obj.Roi,:));

            set(obj.Axes(2), 'XData', obj.XData,...
                'OnsetData', obj.TData2(obj.Roi,:),...
                'OffsetData', obj.TData2(obj.Roi,:),...
                'RatioData', obj.TData2(obj.Roi,:));

            obj.DataUpdateRequired = false();
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'rightarrow'
                    obj.Roi = obj.Roi + 1;
                case 'leftarrow'
                    if obj.Roi > 1
                        obj.Roi = obj.Roi - 1;
                    end
            end
        end
    end
end 