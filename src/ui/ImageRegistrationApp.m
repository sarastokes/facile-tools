classdef ImageRegistrationApp < handle

    properties (SetAccess = private)
        im1             % Fixed image
        im2             % Moving image

        xyFactor        % Translation
        scaleFactor     % Scale
        stretchFactor   % Stretch
        rotationFactor  % Rotation

        figureHandle
        axHandle 
        zoomHandle
        colorChannels = 'red-cyan'
        logStretch = false;
    end
    
    properties (Dependent = true)    
        imAdj           % Adjusted version of 2nd image
    end

    methods 
        function obj = ImageRegistrationApp(im1, im2)
            obj.im1 = im2double(im1);
            obj.im2 = im2double(im2);

            obj.scaleFactor = 1;
            obj.xyFactor = [0 0];
            obj.stretchFactor = int8([0 0]);
            obj.rotationFactor = 0;

            obj.createUi();
        end
        
        function imAdj = get.imAdj(obj)
            imAdj = imtranslate(obj.im2, obj.xyFactor);
            imAdj = imresize(imAdj, obj.scaleFactor);
        end
    end

    % Callback functions
    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            % ONKEYPRESS
            if ismember('shift', evt.Modifier)
                if strcmp(evt.Key, 'z')
                    obj.zoomHandle.Enable = 'on';
                    obj.figureHandle.Name = 'ZOOM MODE ON';
                    return;
                end
                a = 10.0;
            else
                a = 1.0;
            end
            
            if ismember('alt', evt.Modifier)
                switch evt.Key
                    case 'rightarrow'
                        obj.rotationFactor = obj.rotationFactor + a;
                    case 'leftarrow'
                        obj.rotationFactor = obj.rotationFactor - a;
                    otherwise
                        return;
                end
                obj.refresh();
                return
            end
            
            if ismember('control', evt.Modifier)
                switch evt.Key
                    case 'rightarrow'
                        obj.stretchFactor(2) = obj.stretchFactor(2) + a;
                    case 'leftarrow'
                        obj.stretchFactor(2) = obj.stretchFactor(2) - a;
                    case 'uparrow'
                        obj.stretchFactor(1) = obj.stretchFactor(1) + a;
                    case 'downarrow'
                        obj.stretchFactor(1) = obj.stretchFactor(1) - a;
                    otherwise
                        return
                end
                % obj.stretchFactor = round(obj.stretchFactor);
                obj.refresh();
                return
            end

            switch evt.Key
                case 'rightarrow'
                    obj.xyFactor(1) = obj.xyFactor(1) + a;
                case 'leftarrow'
                    obj.xyFactor(1) = obj.xyFactor(1) - a;
                case 'uparrow'
                    obj.xyFactor(2) = obj.xyFactor(2) + a;
                case 'downarrow'
                    obj.xyFactor(2) = obj.xyFactor(2) - a;
                case {'z', 'equal'}
                    obj.scaleFactor = obj.scaleFactor + (a * 0.01);
                case {'x', 'hyphen'}
                    obj.scaleFactor = obj.scaleFactor - (a * 0.01);
                case 'r'  % reset
                    obj.scaleFactor = 1;
                    obj.xyFactor = [0 0];
                    obj.stretchFactor = int8([0 0]);
                    obj.rotationFactor = 0;
                case 'c'
                    if strcmp(obj.colorChannels, 'red-cyan')
                        obj.colorChannels = 'green-magenta';
                    else
                        obj.colorChannels = 'red-cyan';
                    end
                case 'l'
                    if obj.logStretch
                        obj.logStretch = false;
                    else
                        obj.logStretch = true;
                    end
                otherwise
                    return
            end

            obj.refresh();
        end
        
        function onZoomOff(obj, ~, ~)
            obj.zoomHandle.Enable = 'off';
            obj.figureHandle.Name = 'Image Registration App';
        end
        
        function refresh(obj)
            % REFRESH  Updates full UI
            obj.setTranslation();
            obj.setScale();
            obj.setStretch();
            obj.setRotation();
            obj.showImage();
        end
    end

    % User interface functions
    methods (Access = private)
        function showImage(obj)
            % SHOWIMAGE
            image1 = obj.im1;
            image2 = obj.imAdj;
            
            if obj.logStretch
                image1 = log10(image1);
                
                image2(image2 < 0) = 0;
                image2 = log10(image2);
            end
            
            if obj.rotationFactor ~= 0
                image2 = imrotate(image2, obj.rotationFactor);
            end
            
            if any(obj.stretchFactor ~= 0)
                image2 = imresize(image2, size(image2) + double(obj.stretchFactor));
            end
            
            imshowpair(image1, image2,...
                'Parent', obj.axHandle,...
                'ColorChannels', obj.colorChannels);
        end

        function setTranslation(obj)
            % SETTRANSLATION
            set(findobj(obj.figureHandle, 'Tag', 'xTrans'),...
                'String', num2str(obj.xyFactor(1)));
            set(findobj(obj.figureHandle, 'Tag', 'yTrans'),...
                'String', num2str(obj.xyFactor(2)));
        end

        function setScale(obj)
            % SETSCALE
            set(findobj(obj.figureHandle, 'Tag', 'Scale'),...
                'String', num2str(obj.scaleFactor));
        end
        
        function setStretch(obj)
            % SETSTRETCH
            set(findobj(obj.figureHandle, 'Tag', 'Stretch'),...
                'String', sprintf('%u -- %u', obj.stretchFactor));
        end
        
        function setRotation(obj)
            % SETROTATION
            set(findobj(obj.figureHandle, 'Tag', 'Rotation'),...
                'String', num2str(obj.rotationFactor));
        end
            

        function createUi(obj)
            % CREATEUI
            obj.figureHandle = figure(...
                'Name', 'Image Registration App',...
                'DefaultUicontrolFontSize', 12,...
                'KeyPressFcn', @obj.onKeyPress);
            
            mainLayout = uix.HBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');

            obj.axHandle = axes(uipanel(mainLayout, 'BackgroundColor', 'w'));
            hold(obj.axHandle, 'on');
            
            obj.zoomHandle = zoom(obj.axHandle);
            zoomContextMenu = uicontextmenu();
            uimenu(zoomContextMenu,... 
                'Label', 'Zoom off',...
                'Callback', @obj.onZoomOff);
            obj.zoomHandle.UIContextMenu = zoomContextMenu;
            
            infoLayout = uix.VBox('Parent', mainLayout,...
                'BackgroundColor', 'w');
            uicontrol(infoLayout, 'Style', 'text', 'String', 'Translation',...
                'FontWeight', 'bold');
            uicontrol(infoLayout, 'Style', 'text', 'Tag', 'xTrans');
            uicontrol(infoLayout, 'Style', 'text', 'Tag', 'yTrans');
            
            uicontrol(infoLayout, 'Style', 'text', 'String', 'Rotation',...
                'FontWeight', 'bold');
            uicontrol(infoLayout, 'Style', 'text', 'Tag', 'Rotation');
            
            uicontrol(infoLayout, 'Style', 'text', 'String', 'Scale',...
                'FontWeight', 'bold');
            uicontrol(infoLayout, 'Style', 'text', 'Tag', 'Scale');
            
            uicontrol(infoLayout, 'Style', 'text', 'String', 'Stretch',...
                'FontWeight', 'bold');
            uicontrol(infoLayout, 'Style', 'text', 'Tag', 'Stretch');
            
            obj.refresh();

            set(mainLayout, 'Widths', [-1, -0.25]);
            
            fixuilabels(obj.figureHandle);
        end
    end
end 