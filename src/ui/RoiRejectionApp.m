classdef RoiRejectionApp < handle

    properties 
        rois
        regions 
        im 
        labelMatrix 
    end

    properties % (Access = private)
        figureHandle
        axHandle
        imHandle
        overlayHandle
        labelHandle

        cmapOne
        cmapTwo

        originalRegions
        originalRois
        oldRegions
        oldRois
    end

    methods 
        function obj = RoiRejectionApp(im, regions, rois)
            obj.im = im2double(im);
            obj.regions = regions;
            obj.rois = rois;
            obj.labelMatrix = labelmatrix(obj.rois);

            obj.originalRegions = regions;
            obj.originalRois = rois;

            obj.createUi();
        end
    end
    
    % Helper functions
    methods
        function updateHeader(obj, txt)
            h = findobj(obj.figureHandle, 'Tag', 'Header');
            set(h, 'String', txt);
        end
        
        function updateFooter(obj, txt)
            h = findobj(obj.figureHandle, 'Tag', 'Footer');
            set(h, 'String', txt);
        end
    end
    
    % Callback functions
    methods (Access = private)
        function onMouse_labelMatrix(obj, src, ~)
            pt = get(obj.axHandle, 'CurrentPoint');
            clickedPoint = fliplr(ceil(mean(pt(:, 1:2), 1)));
            if sum(obj.labelMatrix(clickedPoint(1), clickedPoint(2))) == 0
                clickedPoint = fliplr(floor(mean(pt(:, 1:2), 1)));
            end
            ind = obj.labelMatrix(clickedPoint(1), clickedPoint(2));
            obj.updateFooter(sprintf('ROI Clicked = %u', ind));
        end
        
        function onKeyPress(obj, ~, evt)
            switch evt.Character
                case 'd'
                    pt = get(obj.axHandle, 'CurrentPoint');
                    clickedPoint = fliplr(ceil(mean(pt(:, 1:2), 1)));
                    if sum(obj.labelMatrix(clickedPoint(1), clickedPoint(2))) == 0
                        clickedPoint = fliplr(floor(mean(pt(:, 1:2), 1)));
                    end
                    ind = obj.labelMatrix(clickedPoint(1), clickedPoint(2));
                    if ind == 0
                        warning('no roi found at location!');
                        return
                    end
                    obj.oldRegions = obj.regions;
                    obj.oldRois = obj.rois;
                    [obj.regions, obj.rois] = roiRemove(obj.regions, obj.rois, ind);

                    obj.labelMatrix = labelmatrix(obj.rois);
                    obj.labelHandle.CData = obj.labelMatrix;
                    
                    obj.updateHeader(sprintf('%u ROIs', obj.rois.NumObjects));
                    drawnow;

                    % delete(obj.overlayHandle); delete(obj.imHandle);
                    % [obj.overlayHandle, obj.imHandle] = roiOverlay(obj.im, obj.rois,...
                    %     'Parent', obj.axHandle);
                    % set([obj.overlayHandle, obj.imHandle], 'Visible', 'off');
                    % colormap(obj.axHandle, obj.cmapTwo);
                case 'u'
                    if isempty(obj.oldRois)
                        return
                    end
                    obj.rois = obj.oldRois;
                    obj.regions = obj.oldRegions;

                    obj.labelMatrix = labelmatrix(obj.rois);
                    obj.labelHandle.CData = obj.labelMatrix;
                case 'z'
                    % Switch displays
            end
        end
    end

    methods (Access = private)
        function createUi(obj)
            % CREATEUI  Initialize user interface
            obj.figureHandle = figure(...
                'Name', 'ROI Rejection App',...
                'KeyPressFcn', @obj.onKeyPress,...
                'Color', 'w');
            
            mainLayout = uix.VBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            uicontrol(mainLayout, 'Style', 'text', 'Tag', 'Header');
            p = uipanel(mainLayout, 'BackgroundColor', 'w');
            obj.axHandle = axes('Parent', p);
            uicontrol(mainLayout, 'Style', 'text', 'Tag', 'Footer');
            set(mainLayout, 'Heights', [30, -1, 30]);

            % [obj.overlayHandle, obj.imHandle] = roiOverlay(obj.im, obj.rois,...
            %     'Parent', obj.axHandle);
            % set([obj.overlayHandle, obj.imHandle], 'Visible', 'off');
            % obj.cmapOne = colormap(obj.axHandle);

            obj.labelHandle = imagesc(obj.axHandle, obj.labelMatrix);
            set(obj.labelHandle, 'ButtonDownFcn', @obj.onMouse_labelMatrix);
            axis(obj.axHandle, 'equal', 'tight', 'off');
            obj.cmapTwo = colormap(obj.axHandle, 'jet');
            obj.cmapTwo = [0 0 0; obj.cmapTwo];
            colormap(obj.axHandle, obj.cmapTwo);

        end
    end
end 