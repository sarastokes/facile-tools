classdef PixelResponseView < handle

    properties 
        imStack
        onMap 
        offMap

        preTime 
        stimTime 
        tailTime 
        
        smoothFac
    end
    
    properties (Dependent)
        imagingArea
    end

    properties % (Access = private)
        figureHandle
        axHandle
        imHandle
    end

    methods 
        function obj = PixelResponseView()
            obj.createUi();
        end
        
        function imagingArea = get.imagingArea(obj)
            h = findByTag(obj.figureHandle, 'ImagingArea');
            imagingArea = h.String{h.Value};
        end
    end

    methods (Access = private)
        function onGo(obj, ~, ~)
            if isempty(obj.imStack)
                warndlg('Upload a video first!');
                return;
            end

            obj.updateStatus('Calculating...');

            obj.preTime =  [str2double(get(findByTag(obj.figureHandle, 'Bkgd1'), 'String')),...
                            str2double(get(findByTag(obj.figureHandle, 'Bkgd2'), 'String'))];
            obj.stimTime = [str2double(get(findByTag(obj.figureHandle, 'During1'), 'String')),...
                            str2double(get(findByTag(obj.figureHandle, 'During2'), 'String'))];
            obj.tailTime = [str2double(get(findByTag(obj.figureHandle, 'After1'), 'String')),...
                            str2double(get(findByTag(obj.figureHandle, 'After1'), 'String'))];
            
            switch obj.imagingArea
                case 'right'
                    iStack = obj.imStack(:, floor(size(obj.imStack, 2)/2):size(obj.imStack, 2), :);
                case 'left'
                    iStack = obj.imStack(:, 1:ceil(size(obj.imStack, 2)/2), :);
                case 'full'
                    iStack = obj.imStack;
            end

            if isempty(obj.smoothFac)
                [obj.onMap, obj.offMap] = pixelOnsetOffsetMap(iStack,...
                    obj.stimTime, obj.tailTime, obj.preTime);
            else
                [obj.onMap, obj.offMap] = pixelOnsetOffsetMap(iStack,...
                    obj.stimTime, obj.tailTime, obj.preTime,...
                    'LowPass', obj.smoothFac);
            end

            obj.updatePlot();

            obj.updateStatus();
        end
        
        function onEditSmooth(obj, src, ~)
            if isempty(src.String)
                obj.smoothFac = [];
                return
            end
            
            try 
                obj.smoothFac = str2double(src.String);
            catch
                obj.smoothFac = [];
                src.String = '';
                warndlg('Invalid numeric input for smoothing');
            end
        end

        function onChangedDisplay(obj, ~, ~)
            if isempty(obj.onMap)
                return
            end
            obj.updatePlot();
        end

        function updatePlot(obj)
            if get(findByTag(obj.figureHandle, 'Offset'), 'Value')
                iMap = obj.offMap;
                title(obj.axHandle, 'Offset');
            else
                iMap = obj.onMap;
                title(obj.axHandle, 'Onset');
            end
            
            if get(findByTag(obj.figureHandle, 'GaussFilt'), 'Value')
                iMap = imgaussfilt(iMap, 1.5);
            end
            delete(obj.imHandle); cla(obj.axHandle);
            obj.imHandle = symMap(iMap, 'ParentHandle', obj.axHandle);
        end

        function updateStatus(obj, str)
            if nargin < 2
                str = '';
            end
            h = findobj(obj.figureHandle, 'Tag', 'StatusBox');
            set(h, 'String', str);
            drawnow;
        end

        function onLoadVideo(obj, varargin)
            obj.updateStatus('Loading...');
            newStack = loadVideo();
            if ~isempty(newStack)
                obj.imStack = newStack;
            end
            imagesc(obj.axHandle, mean(obj.imStack, 3));
            axis(obj.axHandle, 'equal', 'tight', 'off');
            obj.updateStatus();
        end

        function onExportImage(obj, ~, ~)
            newAxes = exportFigure(obj.axHandle);
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'OnsetMapViewer',...
                'DefaultUiControlFontSize', 12,...
                'Color', 'w');

            mainLayout = uix.HBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            obj.axHandle = axes('Parent', uipanel(mainLayout, 'BackgroundColor', 'w'));
            uiLayout = uix.VBox('Parent', mainLayout,...
                'BackgroundColor', 'w');
            uicontrol(uiLayout, 'Style', 'text', 'String', '',...
                'Tag', 'StatusBox');
            uicontrol(uiLayout, 'Style', 'push', 'String', 'Load video',...
                'Callback', @obj.onLoadVideo);
            ao.ui.UiUtility.verticalBoxWithBoldLabel(uiLayout, 'Imaging Area',... 
                'Style', 'popup',... 
                'String', {'full', 'left', 'right'},...
                'Tag', 'ImagingArea');
            [h1, h2] = ao.ui.UiUtility.verticalBoxWithTwoCells(uiLayout,...
                'Background', 'Bkgd1', 'Bkgd2');
            h1.String = '1'; h2.String = '250';
            [h1, h2] = ao.ui.UiUtility.verticalBoxWithTwoCells(uiLayout,...
                'Onset', 'During1', 'During2');
            h1.String = '251'; h2.String = '750';
            [h1, h2] = ao.ui.UiUtility.verticalBoxWithTwoCells(uiLayout,...
                'Offset', 'After1', 'After2');
            h1.String = '751'; h2.String = '1250';
            uicontrol(uiLayout, 'Style', 'check',... 
                'String', 'Gaussian filter', 'Tag', 'GaussFilt',...
                'Callback', @obj.onChangedDisplay);
            ao.ui.UiUtility.horizontalBoxWithLabel(uiLayout, 'Smooth',...
                'Style', 'edit', 'Tag', 'Smooth',...
                'Callback', @obj.onEditSmooth);
            uicontrol(uiLayout, 'Style', 'check', ...
                'String', 'Show offset', 'Tag', 'Offset',...
                'Callback', @obj.onChangedDisplay);
            uicontrol(uiLayout, 'Style', 'push',...
                'String', 'Go!', 'FontWeight', 'bold',...
                'Callback', @obj.onGo);
            uicontrol(uiLayout, 'Style', 'push',...
                'String', 'Export Image',...
                'Callback', @obj.onExportImage);
            set(mainLayout, 'Widths', [-3, -1]);
        end
    end
end 