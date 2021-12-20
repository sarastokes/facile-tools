classdef ImageComparisonApp < handle 

    properties (SetAccess = private)
        im1
        im2 
        im3
    end

    properties % (Access = private)
        figureHandle
        axHandle
        imHandle
        zoomHandle
        
        statusBar
        infoBar

        alphaFactor
    end

    methods 
        function obj = ImageComparisonApp(im1, im2)
            obj.im1 = im2double(im1);
            obj.im2 = im2double(im2);

            obj.im3 = imfuse(im1, im2,... 
                'Scaling', 'joint',... 
                'ColorChannels', [1 2 0]);

            obj.alphaFactor = 0;

            obj.createUi();
        end

    end

    methods (Access = private)
        function onZoomButtonDown(obj, src, evt)
            % obj.zoomHandle.Enable = 'off';
            assignin('base', 'src', src);
            assignin('base', 'evt', evt);
        end

        function onKeyPress(obj, ~, evt)
            if ismember(evt.Modifier, 'shift')
                inc = 0.1;
            else
                inc = 0.01;
            end

            switch evt.Key 
                case 'rightarrow'
                    obj.alphaFactor = obj.alphaFactor + inc;
                case 'leftarrow'
                    obj.alphaFactor = obj.alphaFactor - inc;
                case 'z'
                    obj.zoomHandle.Enable = 'on';
                    obj.statusBar.String = 'Zoom Mode is ON';
                    return;
                case 'r'
                    obj.alphaFactor = 0;
                    zoom(obj.axHandle, 'reset');
                    obj.zoomHandle.Enable = 'off';
                otherwise
                    return;
            end

            % Keep within bounds
            if obj.alphaFactor > 1
                obj.alphaFactor = 1;
            elseif obj.alphaFactor < -1
                obj.alphaFactor = -1;
            end

            obj.refresh();
        end
    end

    methods (Access = private)
        function onZoomOff(obj, ~, ~)
            obj.zoomHandle.Enable = 'off';
            obj.statusBar.String = '';
        end

        function refresh(obj)
            % REFRESH  Updates image
            newIm = obj.im3;
            fac = 1 - abs(obj.alphaFactor);
            
            if obj.alphaFactor > 0
                newIm(:,:,2) = fac * newIm(:,:,2);
                co = hex2rgb('ff4040');
            elseif obj.alphaFactor < 0
                newIm(:,:,1) = fac * newIm(:,:,1);
                co = hex2rgb('00cc4d');
            elseif obj.alphaFactor == 0
                co = [0 0 0];
            end
            set(obj.infoBar, 'String', num2str(fac),...
                'ForegroundColor', co);

            % Preserve zoomed in axis limits
            x = xlim(obj.axHandle);
            y = ylim(obj.axHandle);
            imshow(newIm, 'Parent', obj.axHandle);
            xlim(obj.axHandle, x);
            ylim(obj.axHandle, y);
        end

        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'ImageComparisonApp',...
                'DefaultUicontrolFontSize', 12,...
                'DefaultUicontrolBackgroundColor', 'w',...
                'KeyPressFcn', @obj.onKeyPress);

            mainLayout = uix.VBox('Parent', obj.figureHandle);
            obj.statusBar = uicontrol(mainLayout,...
                'Style', 'text', 'String', '',...
                'FontWeight', 'bold');

            obj.axHandle = axes(uipanel(mainLayout));
            obj.imHandle = imshow(obj.im3,... 
                'Parent', obj.axHandle);

            obj.infoBar = uicontrol(mainLayout,...
                'Style', 'text', 'String', '');
                
            obj.zoomHandle = zoom(obj.axHandle);
            zoomContextMenu = uicontextmenu();
            zoomMenu = uimenu(zoomContextMenu,... 
                'Label', 'Zoom off',...
                'Callback', @obj.onZoomOff);
            obj.zoomHandle.UIContextMenu = zoomContextMenu;
            
            
            set(mainLayout, 'Heights', [-1 -8 -1]);
            fixuilabels(obj.figureHandle);
            
            obj.refresh();
        end
    end
end 