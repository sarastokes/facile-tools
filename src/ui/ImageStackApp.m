classdef ImageStackApp < handle
% IMAGESTACKAPP  View a stack of EM screenshots
% Inputs:
%       images      ImageStack or filepath to images
%       Provide a 2nd input to reverse the stack

    properties (Transient = true)
        currentNode
        handles
        toolbar
        imageBounds = [];
    end

    methods

        function obj = ImageStackApp(imStack, filtFcn, flipStack)
            % IMAGESTACKAPP  View a stack of EM screenshots
            %
            % Inputs:
            %   images      ImageStack or folder name
            % Optional inputs
            %   filtFcn     Function handle to filter image files
            %       Default: @(x) endsWith(x, [".png", ".tif", ".tiff", ".jpg"])
            %   flipStack   logical (default = false)
            %       Reverse the stack order
            % --------------------------------------------------------------

            imStack = convertCharsToStrings(imStack);
            assert(isa(imStack, 'ImageStack') || isfolder(imStack),...
                'Input must be ImageStack or filepath to create new ImageStack');
            if nargin < 2
                filtFcn = [];
            end

            if nargin < 3
                flipStack = false;
            end

            if isstring(imStack)
                imStack = ImageStack(imStack, [], filtFcn);
            end

            if flipStack
                obj.currentNode = imStack.tail;
            else
                obj.currentNode = imStack.head;
            end

            obj.createUi();
        end

        function createUi(obj)
            obj.handles.fh = uifigure(...
                'Name', 'Image Stack View',...
                'Menubar', 'none',...
                'Toolbar', 'none',...
                'NumberTitle', 'off',...
                'DefaultUicontrolBackgroundColor', 'w',...
                'DefaultUicontrolFontName', 'Segoe Ui',...
                'DefaultUicontrolFontSize', 10,...
                'KeyPressFcn', @obj.onKeyPress);
            pos = get(obj.handles.fh, 'Position');
            obj.handles.fh.Position = [pos(1), pos(2)-200, 550, 600];

            obj.toolbar.file = uimenu('Parent', obj.handles.fh,...
                'Label', 'Process image');
            uimenu('Parent', obj.toolbar.file,...
                'Label', 'Crop',...
                'Callback', @obj.onToolbarCrop);
            uimenu('Parent', obj.toolbar.file,...
                'Label', 'Full size',...
                'Callback', @obj.onToolbarFullSize);
            obj.toolbar.file = uimenu('Parent', obj.handles.fh,...
                'Label', 'Export');
            uimenu('Parent', obj.toolbar.file,...
                'Label', 'Export image',...
                'Callback', @obj.onToolbarExport);

            mainLayout = uigridlayout(obj.handles.fh, [2 1], ...
                "RowHeight", {'12x', '1x'}, 'BackgroundColor', 'w');
            obj.handles.ax = uiaxes( ...
                'Parent', mainLayout,...
                'Color', 'w');
            uiLayout = uigridlayout(mainLayout, [1 3],...
                "ColumnWidth", {'1x', '4x', '1x'},...
                "BackgroundColor", "w");
            obj.handles.pb.prev = uibutton(uiLayout,...
                'Text', '<--',...
                'ButtonPushedFcn', @obj.onViewSelectedPrevious);
            obj.handles.tx.frame = uilabel(uiLayout,...
                'BackgroundColor', 'w',...
                'FontSize', 10,...
                'Text', obj.currentNode.name);
            obj.handles.pb.prev = uibutton(uiLayout,...
                'Text', '-->',...
                'ButtonPushedFcn', @obj.onViewSelectedNext);

            obj.currentNode.show(obj.handles.ax);

            set(findall(obj.handles.fh, 'Style', 'push'),...
                'BackgroundColor', 'w',...
                'FontSize', 10,...
                'FontWeight', 'bold');
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, event)
            switch event.Key
                case 'rightarrow'
                    obj.nextView();
                case 'leftarrow'
                    obj.previousView();
            end
        end

        function onViewSelectedPrevious(obj, ~, ~)
            obj.previousView();
        end

        function previousView(obj)
            if isempty(obj.currentNode.previous)
                return;
            end

            obj.currentNode = obj.currentNode.previous;
            obj.showImage();
            set(obj.handles.tx.frame, 'Text', obj.currentNode.name);
        end

        function onViewSelectedNext(obj, ~, ~)
            obj.nextView();
        end

        function nextView(obj)
            if isempty(obj.currentNode.next)
                return;
            end

            obj.currentNode = obj.currentNode.next;
            obj.showImage();
            set(obj.handles.tx.frame, 'Text', obj.currentNode.name);
        end

        function showImage(obj)
            obj.currentNode.show(obj.handles.ax);
            if ~isempty(obj.imageBounds)
                xlim(obj.handles.ax, obj.imageBounds([1 3]));
                ylim(obj.handles.ax, obj.imageBounds([2 4]));
            end
        end

        function onToolbarCrop(obj, ~, ~)
            obj.imageBounds = round(rect2pts(getrect(obj.handles.ax)));
            disp(obj.imageBounds);
        end

        function onToolbarFullSize(obj, ~, ~)
            obj.imageBounds = [];
        end

        function onToolbarExport(obj, ~, ~)
            im = findobj(obj.handles.ax, 'Type', 'Image');
            im = im.CData;
            if ~isempty(obj.imageBounds)
                im = im(obj.imageBounds(1):obj.imageBounds(3), ...
                        obj.imageBounds(2):obj.imageBounds(4));
            end
            [fName, fPath] = uiputfile('*.png', obj.currentNode.name);
            if isequal(fName, 0) || isequal(fPath, 0)
                return
            else
                fprintf('Saving as %s\n', [fPath, filesep, fName]);
                imwrite(im, [fPath, filesep, fName], 'png', 'BitDepth', 16);
            end
        end
    end
end