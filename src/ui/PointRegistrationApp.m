classdef PointRegistrationApp < handle

    properties 
        im1
        im2 
        tform  
    end

    properties 
        figureHandle
        axHandle1
        axHandle2
    end

    methods 
        function obj = PointRegistrationApp(im1, im2, tform)
            obj.im1 = im1;
            obj.im2 = im2;
            obj.tform = tform;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onPressConvert(obj, ~, ~)
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'PointRegistrationApp',...
                'Color', 'w');
            
            mainLayout = uix.HBox(obj.figureHandle);
            imLayout = uix.VBox(mainLayout);
            uiLayout = uix.HBox(mainLayout);
            
            obj.axHandle1 = axes(uipanel(imLayout, 'BackgroundColor', 'w'));
            obj.axHandle2 = axes(uipanel(imLayout, 'BackgroundColor', 'w'));
            imshow(obj.axHandle1, obj.im1);
            imshow(obj.axHandle2, obj.im2);
            hold([obj.axHandle1, obj.axHandle2], 'on');
             axis([obj.axHandle1, obj.axHandle2], 'tight');
            
            lm = ao.ui.LayoutManager();
            lm.horizontalBoxWithBoldLabel(uiLayout, 'X: ',...
                'Style', 'edit', 'Tag', 'xpt');
            lm.horizontalBoxWithBoldLabel(uiLayout, 'Y: ',...
                'Style', 'edit', 'Tag', 'ypt');
            uicontrol(uiLayout,...
                'Style', 'push', 'String', 'Convert',...
                'Callback', @obj.onPressConvert);

            set(mainLayout, 'Widths', [-3, -1]);
        end
    end
end 