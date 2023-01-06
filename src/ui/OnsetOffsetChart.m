classdef OnsetOffsetChart < matlab.graphics.chartcontainer.ChartContainer

    properties
        XData = NaN 
        OnsetData = NaN 
        OffsetData = NaN 
        RatioData = NaN 
        TitleText = ''
    end

    properties (Access = private, Transient, NonCopyable)
        OnsetLine
        OffsetLine
        RatioLine
        ZeroLine
    end

    methods (Access = protected)
        function setup(obj)
            ax = obj.getAxes();

            hold(ax, 'on');
            obj.ZeroLine = line(ax, NaN, NaN,...
                'Color', [0.4 0.4 0.4], 'LineWidth', 0.5);
            obj.OnsetLine = line(ax, NaN, NaN,...
                'Color', [0.5 1 0.5], 'LineWidth', 1.5, 'Marker', 'o');
            obj.OffsetLine = line(ax, NaN, NaN,...
                'Color', [1 0.5 0.5], 'LineWidth', 1.5, 'Marker', 'o');
            obj.RatioLine = line(ax, NaN, NaN,...
                'Color', [0 0 0], 'LineWidth', 1.5, 'Marker', 'o');
            grid(ax, 'on');
            hold(ax, 'off');
        end

        function update(obj)
            set(obj.OnsetLine, 'XData', obj.XData, 'YData', obj.OnsetData);
            set(obj.OffsetLine, 'XData', obj.XData, 'YData', obj.OffsetData);
            set(obj.RatioLine, 'XData', obj.XData, 'YData', obj.RatioData);
            ax = obj.getAxes();
            y = ax.YLim;
            set(obj.ZeroLine, 'XData', ax.XLim, 'YData', [0 0]);
            axis(ax, 'tight');
            ax.YLim = y;
        end
    end
end