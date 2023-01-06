classdef TuningCurveViewer < handle

    properties (SetAccess = private)
        tempHzs(1,:)                double
        roiUIDs(:,1)                string
        numRois(1,1)                double 
        currentRoi(1,1)             double
        squareData                  double 
        sineData                    double
        onData                      double
        offData                     double
    end

    properties (Access = private)
        Figure
        Axes
        roiLabel
        squareLine(1,1)             matlab.graphics.primitive.Line
        sineLine(1,1)               matlab.graphics.primitive.Line
        onLine(1,1)                 matlab.graphics.primitive.Line
        offLine(1,1)                matlab.graphics.primitive.Line
    end

    methods 
        function obj = TuningCurveViewer(tempHzs, squareData, sineData, onData, offData, roiUIDs)
            obj.tempHzs = tempHzs;
            obj.roiUIDs = roiUIDs;
            obj.squareData = squareData;
            obj.sineData = sineData;
            obj.onData = onData;
            obj.offData = offData;

            obj.numRois = size(obj.squareData, 1);
            obj.currentRoi = 1;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentRoi == 1
                        return;
                    end
                    obj.currentRoi = obj.currentRoi - 1;
                    obj.updateView();
                case 'rightarrow'
                    obj.currentRoi = obj.currentRoi + 1;
                    obj.updateView();
            end
        end

        function updateView(obj)
            obj.squareLine.YData = obj.squareData(obj.currentRoi,:);
            obj.sineLine.YData = obj.sineData(obj.currentRoi,:);
            obj.offLine.YData = obj.offData(obj.currentRoi,:);
            obj.onLine.YData = obj.onData(obj.currentRoi,:);
            obj.roiLabel.Text = sprintf('Roi %u (%s)', ...
                obj.currentRoi, obj.roiUIDs(obj.currentRoi));
        end

        function createUi(obj)
            obj.Figure = uifigure(...
                'KeyPressFcn', @obj.onKeyPress);
            layout = uigridlayout(obj.Figure, [2 1]);

            obj.roiLabel = uilabel('Parent', layout,... 
                'Text', sprintf('Roi %u', 1),...
                'HorizontalAlignment', 'center');

            obj.Axes = uiaxes('Parent', layout);
            hold(obj.Axes, 'on');
            grid(obj.Axes, 'on');
            obj.Axes.XLim = [1 max(obj.tempHzs)];
            obj.Axes.XScale = 'log';
            obj.Axes.XTick = obj.tempHzs;
            obj.Axes.XMinorGrid = 'off';

            line([obj.tempHzs(1) obj.tempHzs(end)], [0 0],... 
                'Color', [0.5 0.5 0.5]);
            obj.squareLine = line(obj.Axes,... 
                obj.tempHzs(1:size(obj.squareData,2)),... 
                obj.squareData(1, :),...
                'Marker', 'o', 'Color', hex2rgb('334de6'),...
                'MarkerFaceColor', hex2rgb('334de6'));
            obj.sineLine = line(obj.Axes,...
                obj.tempHzs(1:size(obj.sineData,2)),...
                squeeze(obj.sineData(1,:)),...
                'Marker', 'o', 'Color', rgb('light orange'),...
                'MarkerFaceColor', rgb('light orange'));
            
            obj.onLine = line(obj.Axes,...
                obj.tempHzs(1:size(obj.onData, 2)),...
                obj.onData(1,:),...
                'Marker', 'o', 'Color', rgb('green blue'),...
                'MarkerFaceColor', rgb('green blue'));
            disp(size(obj.offData))
            obj.offLine = line(obj.Axes,...
                obj.tempHzs(1:size(obj.offData,2)),...
                obj.offData(1, :),...
                'Marker', 'o', 'Color', hex2rgb('ff4040'),...
                'MarkerFaceColor', hex2rgb('ff4040'));
            layout.RowHeight = {20, '1x'};
        end
    end
end 