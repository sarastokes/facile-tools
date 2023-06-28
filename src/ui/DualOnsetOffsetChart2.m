classdef DualOnsetOffsetChart2 < handle

    properties (SetAccess = private)
        TData1
        TData2
        XData
        Names 
        Thresh

        Roi
    end

    properties %(Access = private)
        figureHandle
        axHandle1
        axHandle2
        axHandle3
        imHandle

        OnsetLine1
        OnsetLine2
        OffsetLine1
        OffsetLine2
        RatioLine1
        RatioLine2

        SummaryLine1
        SummaryLine2
    end

    methods
        function obj = DualOnsetOffsetChart2(TData1, TData2, varargin)
            obj.TData1 = TData1;
            obj.TData2 = TData2;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'XData', 1:numel(obj.TData1(1,:)), @isnumeric);
            addParameter(ip, 'Names', []);
            addParameter(ip, 'Thresh', 0.2, @isnumeric);
            parse(ip, varargin{:});

            obj.XData = ip.Results.XData;
            obj.Thresh = ip.Results.Thresh;
            if ~isempty(ip.Results.Names)
                assert(numel(ip.Results.Names) == 2, 'There must be two names!');
                obj.Names = ip.Results.Names;
            end

            obj.Roi = 1;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key 
            case 'rightarrow'
                if obj.Roi < height(obj.TData1)
                    obj.Roi = obj.Roi + 1;
                    obj.update();
                end
            case 'leftarrow'
                if obj.Roi > 1
                    obj.Roi = obj.Roi - 1;
                    obj.update();
                end
            end
        end
    end

    methods (Access = private)
        function update(obj)
            title(obj.axHandle3, sprintf('Roi %u', obj.Roi));

            set(obj.OnsetLine1, 'YData', obj.TData1.onset(obj.Roi,:));
            set(obj.OnsetLine2, 'YData', obj.TData2.onset(obj.Roi,:));
            set(obj.OffsetLine1, 'YData', obj.TData1.offset(obj.Roi,:));
            set(obj.OffsetLine2, 'YData', obj.TData2.offset(obj.Roi,:));
            set(obj.RatioLine1, 'YData', obj.TData1.onoff(obj.Roi,:));
            set(obj.RatioLine2, 'YData', obj.TData2.onoff(obj.Roi,:));
            set(obj.SummaryLine1, 'YData', obj.TData1.onoff(obj.Roi,:));
            set(obj.SummaryLine2, 'YData', obj.TData2.onoff(obj.Roi,:));
            
            setYAxisZScore(obj.axHandle1, [0.5 1]);
            if obj.axHandle1.YLim(1) == 0
                obj.axHandle1.YLim(1) = -0.1;
            end

            weights = -1 * ones(2, numel(obj.SummaryLine1.YData));
            weights(1, obj.SummaryLine1.YData > 0) = 1;
            weights(1, abs(obj.SummaryLine1.YData) < obj.Thresh) = 0;  
            weights(2, obj.SummaryLine2.YData > 0) = 2;
            weights(2, abs(obj.SummaryLine2.YData) < obj.Thresh) = 0;
            obj.imHandle.CData = weights;
        end

        function createUi(obj)
            obj.figureHandle = figure(...
                'KeyPressFcn', @obj.onKeyPress);
            obj.figureHandle.Position(4) = obj.figureHandle.Position(4)-50;
            
            mainLayout = uix.HBox('Parent', obj.figureHandle);
            subplotLayout1 = uix.VBox('Parent', mainLayout);
            subplotLayout2 = uix.VBox('Parent', mainLayout);
            set(mainLayout, 'Widths', [-1 -1]);
            obj.axHandle1 = axes(uipanel(subplotLayout1));
            obj.axHandle2 = axes(uipanel(subplotLayout1));
            set(subplotLayout1, 'Heights', [-1 -1]);
            obj.axHandle3 = axes(uipanel(subplotLayout2));
            ax4 = axes(uipanel(subplotLayout2));
            set(subplotLayout2, 'Heights', [-3 -1]);

            linkaxes([obj.axHandle1, obj.axHandle2, obj.axHandle3], 'x');
            linkaxes([obj.axHandle1, obj.axHandle2, obj.axHandle3], 'y');
            grid([obj.axHandle1, obj.axHandle2, obj.axHandle3], 'on');
            hold([obj.axHandle1, obj.axHandle2, obj.axHandle3], 'on');

            if ~isempty(obj.Names)
                title(obj.axHandle1, obj.Names(1));
                title(obj.axHandle2, obj.Names(2));
            end

            line(obj.axHandle1, 'XData', obj.XData([1, end]),...
                'YData', [0 0], 'LineWidth', 0.75, 'Color', [0.2 0.2 0.2]);
            line(obj.axHandle2, 'XData', obj.XData([1, end]),...
                'YData', [0 0], 'LineWidth', 0.75, 'Color', [0.2 0.2 0.2]);

            obj.OffsetLine1 = line(obj.axHandle1, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [1 0.5 0.5], 'LineWidth', 1.25, 'Marker', 'o');
            obj.OffsetLine2 = line(obj.axHandle2, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [1 0.5 0.5], 'LineWidth', 1.25, 'Marker', 'o');
            
            obj.OnsetLine1 = line(obj.axHandle1, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [0.5 0.5 1], 'LineWidth', 1.25, 'Marker', 'o');
            obj.OnsetLine2 = line(obj.axHandle2, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [0.5 0.5 1], 'LineWidth', 1.25, 'Marker', 'o');
             
            obj.RatioLine1 = line(obj.axHandle1, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [0.1 0.1 0.1], 'LineWidth', 1.25, 'Marker', 'o');
            obj.RatioLine2 = line(obj.axHandle2, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [0.1 0.1 0.1], 'LineWidth', 1.25, 'Marker', 'o'); 

            obj.SummaryLine1 = line(obj.axHandle3, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [1 0.3 0.3], 'LineWidth', 1.25, 'Marker', 'o');
            obj.SummaryLine2 = line(obj.axHandle3, 'XData', obj.XData,... 
                'YData', NaN(size(obj.XData)),... 
                'Color', [0.3 1 0.3], 'LineWidth', 1.25, 'Marker', 'o');

            obj.imHandle = imagesc(ax4, zeros(1, numel(obj.XData)), 'XData', obj.XData);
            colormap(ax4, [0 0 0; 0.5 0.5 0.5; 1 0 0; 0 1 0]);
            caxis(ax4, [-1 2]);
            axis(ax4, 'tight');

            xlim(obj.axHandle1, [floor(obj.XData(1)), ceil(obj.XData(end))]);
            % xlim(obj.axHandle2, [floor(obj.XData(1)), ceil(obj.XData(end))]);

            obj.update();
        end
    end
end