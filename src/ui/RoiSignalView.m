classdef RoiSignalView < handle

    properties (SetAccess = private)
        imStack
        roiMask
        sampleRate 
    end

    properties (Access = private)
        avgImage
        currentRoi
        totalRois
        figureHandle
        roiAxis
        roiHandle
        signalHandle
    end

    methods 
        function obj = RoiSignalView(imStack, roiMask, sampleRate)
            if nargin < 3
                obj.sampleRate = 25;
            else
                obj.sampleRate = sampleRate;
            end

            obj.imStack = imStack;

            if isstruct(roiMask)
                obj.roiMask = labelmatrix(roiMask);
            else
                obj.roiMask = roiMask;
            end

            obj.currentRoi = 1;
            obj.totalRois = numel(unique(obj.roiMask)) - 1;
            obj.avgImage = squeeze(mean(obj.imStack, 3));

            obj.createUi();
        end
        
    end

    methods (Access = private)
        function changeRoi(obj)

            mask = obj.roiMask == obj.currentRoi;
            
            set(obj.roiHandle, 'CData', mask, 'AlphaData', 0.3 * mask);
            
            signal = roiSignal(obj.imStack, mask, obj.sampleRate);
            set(obj.signalHandle, 'YData', signal);

            set(findByTag(obj.figureHandle, 'CurrentRoi'),...
                'String', sprintf('ROI = %u', obj.currentRoi));
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            assignin('base', 'evt', evt);            
            switch evt.Key
                case 'leftarrow'
                    if ismember('shift', evt.Modifier)
                        obj.currentRoi = obj.currentRoi - 10;
                    else
                        obj.currentRoi = obj.currentRoi - 1;
                    end
                case 'rightarrow'
                    if ismember('shift', evt.Modifier)
                        obj.currentRoi = obj.currentRoi + 10;
                    else
                        obj.currentRoi = obj.currentRoi + 1;
                    end
            end
            if obj.currentRoi < 0
                obj.currentRoi = 1;
            elseif obj.currentRoi > obj.totalRois
                obj.currentRoi = obj.totalRois;
            end

            obj.changeRoi()
        end
    end

    methods (Access = private)

        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'RoiSignalView',...
                'Color', 'w',...
                'NumberTitle', 'off',...
                'DefaultUicontrolBackgroundColor', 'w',...
                'DefaultUicontrolFontSize', 10,...
                'Menubar', 'none',...
                'Toolbar', 'none',...
                'KeyPressFcn', @obj.onKeyPress);
            
            mainLayout = uix.VBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            
            roiLayout = uix.HBox('Parent', mainLayout,...
                'BackgroundColor', 'w', 'Padding', 0);
            uiLayout = uix.VBox('Parent', roiLayout,...
                'BackgroundColor', 'w', 'Padding', 10);
            uicontrol(uiLayout,...
                'Style', 'text',...
                'String', 'ROI = 1',...
                'Tag', 'CurrentRoi');
            uicontrol(uiLayout,...
                'Style', 'text',...
                'String', sprintf('Total = %u', obj.totalRois));

            obj.roiAxis = axes(uipanel(roiLayout, 'BackgroundColor', 'w'));
            obj.roiHandle = roiOverlay(obj.avgImage, obj.roiMask == obj.currentRoi,... 
                'Parent', obj.roiAxis);
            
            [signal, xpts] = roiSignal(obj.imStack,... 
                obj.roiMask == obj.currentRoi, obj.sampleRate);

            ax2 = axes(uipanel(mainLayout, 'BackgroundColor', 'w'));
            obj.signalHandle = line(ax2, xpts, signal, 'Color', rgb('navy'));
            grid(ax2, 'on');
            xlabel(ax2, 'Time (sec)');
            ylabel(ax2, 'Signal (f)');
            xlim(ax2, [0, max(xpts)]);

            set(mainLayout, 'Heights', [-1, -1]);
            set(roiLayout, 'Widths', [-1 -2]);

            figPos(obj.figureHandle, 1, 1.5);
        end
    end
end 