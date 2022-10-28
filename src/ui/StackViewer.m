classdef StackViewer < handle

    properties
        imStack

        currentFrame
    end

    properties (Access = protected)
        figureHandle 
        axHandle
        imHandle
    end

    methods
        function obj = StackViewer(imStack)
            obj.imStack = imStack;

            obj.currentFrame = 1;
            obj.createUi();
        end
    end

    % Callbacks
    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentFrame == 1
                        return
                    end
                    obj.currentFrame = obj.currentFrame - 1;
                    obj.updateView();
                case 'rightarrow'
                    if obj.currentFrame == size(obj.imStack,3)
                        return
                    end
                    obj.currentFrame = obj.currentFrame + 1;
                    obj.updateView();
                case 'p'
                    obj.playStack();
                case 'g'
                    obj.saveGif();
                otherwise
                    return 
            end
        end
    end


    % Initialization
    methods (Access = private)
        function playStack(obj)
            obj.currentFrame = 1;
            for i = 1:size(obj.imStack,3)
                obj.currentFrame = i;
                obj.updateView();
                pause(0.025);
                obj.currentFrame = obj.currentFrame + 1;
            end
        end

        function saveGif(obj)
            [fName, fPath] = uiputfile('*.gif');
            if fName == 0
                return
            end
            gif([fPath, filesep, fName], 'Frame', obj.figureHandle, ...
                'DelayTime', 0.1, 'Overwrite', true);
            colorbar('off');
            obj.currentFrame = 1;
            title(obj.axHandle,'');
            drawnow;
            gif
            for i = 1:size(obj.imStack,3)
                obj.currentFrame = i;
                obj.updateView();
                title(obj.axHandle,'');
                drawnow; pause(0.02);
                gif;
            end
            title('Done');
        end

        function updateView(obj)
            obj.imHandle.CData = obj.imStack(:,:,obj.currentFrame);
            title(obj.axHandle, sprintf('Frame %u of %u', obj.currentFrame, size(obj.imStack,3)));
        end

        function createUi(obj)

            obj.figureHandle = figure('Name', 'StackViewer',...
                'Color', 'w',...
                'KeyPressFcn', @obj.onKeyPress);
            obj.figureHandle.Position(3)=obj.figureHandle.Position(3) - 50;
            mainLayout = uix.HBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            obj.axHandle = axes('Parent', uipanel(mainLayout, 'BackgroundColor', 'w'));
            obj.imHandle = imagesc(obj.imStack(:,:,1));
            colormap(obj.axHandle, 'gray');
            caxis(obj.axHandle, max(abs(obj.imStack(:))) * [-1 1]);
            axis(obj.axHandle, 'tight');
            axis(obj.axHandle, 'equal');
            axis(obj.axHandle, 'off');
            colorbar(obj.axHandle);
            title(obj.axHandle, sprintf('Frame %u of %u', obj.currentFrame, size(obj.imStack,3)));
        end
    end
end