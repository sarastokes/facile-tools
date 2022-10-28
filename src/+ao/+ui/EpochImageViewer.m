classdef EpochImageViewer < handle

    properties (SetAccess = private)
        data 
        totalEpochs
        currentEpoch 
        
        logStretch
        threshold
        useVideo
    end

    properties (Hidden, Access = private)
        figureHandle
        titleHandle
        histHandle
        refHandle
        axHandle
        imHandle
    end

    methods 
        function obj = EpochImageViewer(data)
        
            obj.data = data;
            
            obj.totalEpochs = numel(obj.data.epochIDs);
            obj.currentEpoch = 1;
            % Default values
            obj.logStretch = false;
            obj.threshold = 0;
            obj.useVideo = false;

            obj.createUi();
            obj.update();
        end
    end

    methods (Access = private)
        function update(obj)
            epochID = obj.data.idx2epoch(obj.currentEpoch);
            
            set(obj.titleHandle, 'String', 'Loading...'); drawnow;
            
            % Don't load reference image each time, for now (use 'r')
            % im = obj.data.loadRefImage(epochID);
            cla(obj.refHandle)

            try
                if obj.useVideo
                    im = obj.data.loadVideo(epochID);
                else
                    im = obj.data.loadImage(epochID, 'Log', obj.logStretch);
                end
            catch
                obj.imHandle.CData = [0 0; 0 0];
                
                set(obj.titleHandle, 'String', [int2fixedwidthstr(epochID, 4), '- NOT FOUND!!!']);
                return
            end

            axes(obj.histHandle);
            yScale = get(obj.histHandle, 'YScale');
            imhist(im(:));
            set(obj.histHandle, 'YScale', yScale);

            if obj.threshold ~= uint8(0)
                fprintf('Thresholding %u points\n', nnz(im <= obj.threshold));
                im(im <= obj.threshold) = uint8(0);
            end

            if obj.useVideo
                im = squeeze(mean(im, 3));
                if obj.logStretch
                    im = log10(im);
                end
            end

            h = findobj(obj.figureHandle, 'Tag', 'Adjustment');
            switch h.String{h.Value}
                case 'imadjust'
                    obj.imHandle.CData = imadjust(im);
                case 'histeq'
                    obj.imHandle.CData = histeq(im);
                case 'adapthisteq'
                    obj.imHandle.CData = adapthisteq(im);
                case 'stretchlim'
                    obj.imHandle.CData = imadjust(im, stretchlim(im), [], 1.2);
                otherwise
                    obj.imHandle.CData = im;
            end
            
            set(obj.titleHandle, 'String', int2fixedwidthstr(epochID, 4));
        end

    end

    methods (Access = private)
        function onKeyPress(obj, ~, event)
            switch event.Key
                case 'rightarrow'
                    if obj.currentEpoch == obj.totalEpochs
                        return
                    end
                    obj.currentEpoch = obj.currentEpoch + 1;
                    obj.update();
                case 'leftarrow'
                    if obj.currentEpoch == 1
                        return
                    end
                    obj.currentEpoch = obj.currentEpoch - 1;
                    obj.update();
                case 'l'
                    if strcmp(obj.histHandle.YScale, 'linear')
                        set(obj.histHandle, 'YScale', 'log');
                    else
                        set(obj.histHandle, 'YScale', 'linear');
                    end
                case 'r'
                    im = obj.data.loadRefImage(obj.data.idx2epoch(obj.currentEpoch));
                    imagesc(obj.refHandle, im);
                    axis(obj.refHandle, 'equal');
                    axis(obj.refHandle, 'tight');
                    axis(obj.refHandle, 'off');
                    colormap(obj.refHandle, 'gray');
            end
        end

        function onEditThreshold(obj, src, ~)
            try 
                thresholdValue = str2double(src.String);
                obj.threshold = uint8(thresholdValue);
                obj.update();
            catch
                warndlg('Invalid input!');
                src.Value = '0';
            end
        end
        
        function onChangedColormap(obj, src, ~)
            cMap = src.String{src.Value};
            switch cMap
                case 'cyan hot'
                    colormap(obj.axHandle, cyan_hot_lut());
                otherwise
                    colormap(obj.axHandle, cMap);
            end
        end

        function onChangedParameter(obj, ~, ~)
            obj.update();
        end

        function onCheckLog(obj, src, ~)
            if src.Value
                obj.logStretch = true;
                set(findByTag(obj.figureHandle, 'Contrast'), 'Value', 0);
            else
                obj.logStretch = false;
                set(findByTag(obj.figureHandle, 'Contrast'), 'Value', 1);
            end
            obj.update();
        end

        function onCheckVideo(obj, src, ~)
            if src.Value
                obj.useVideo = true;
                set(findByTag(obj.figureHandle, 'Log'), 'Value', 0);
            else
                obj.useVideo = false;
                set(findByTag(obj.figureHandle, 'Log'), 'Value', 1);
            end
            obj.update();
        end

        function onPushExport(obj, ~, ~)
            exportFigure(obj.axHandle);
        end
    end

    methods (Access = private)
        function createUi(obj)
            id = [num2str(double(obj.data.source)), '_', char(obj.data.experimentDate)];
            obj.figureHandle = figure(...
                'Name', [id, ' - Epoch Image Viewer'],...
                'Menubar', 'none',...
                'Toolbar', 'none',...
                'NumberTitle', 'off',...
                'KeyPressFcn', @obj.onKeyPress);
            
            mainLayout = uix.VBox('Parent', obj.figureHandle);
            obj.titleHandle = uicontrol(mainLayout,...
                'Style', 'text', 'String', '');
            
            plotLayout = uix.HBoxFlex('Parent', mainLayout);
            obj.axHandle = axes('Parent', uipanel(plotLayout));
            hold(obj.axHandle, 'on');
            axis(obj.axHandle, 'tight', 'equal', 'off');
            colormap(obj.axHandle, 'gray');
            obj.imHandle = imagesc(obj.axHandle, [0 0; 0 0]);
            
            subplotLayout = uix.VBox('Parent', plotLayout);
            obj.histHandle = axes('Parent', uipanel(subplotLayout));
            obj.refHandle = axes('Parent', uipanel(subplotLayout));

            uiLayout = uix.HBox('Parent', mainLayout);

            uicontrol(uiLayout,...
                'Style', 'checkbox',...
                'String', 'Log stretch',...
                'Value', 0,...
                'Tag', 'Log',...
                'Callback', @obj.onCheckLog);
            uicontrol(uiLayout,...
                'Style', 'popupmenu',...
                'String', {'none', 'imadjust', 'stretchlim', 'histeq', 'adapthisteq'},...
                'Value', 1,...
                'Tag', 'Adjustment',...
                'Callback', @obj.onChangedParameter);
            thresholdLayout = uix.VBox('Parent', uiLayout,...
                'BackgroundColor', 'w');
            uicontrol(thresholdLayout,... 
                'Style', 'text', 'String', 'Threshold');
            uicontrol(thresholdLayout,...
                'Style', 'edit', 'String', '0',...
                'Callback', @obj.onEditThreshold);
            uicontrol(uiLayout,...
                'Style', 'popup',...
                'String', {'gray', 'cyan hot', 'pink', 'parula'},...
                'Tag', 'Colormap',...
                'Callback', @obj.onChangedColormap);
            uicontrol(uiLayout,...
                'Style', 'checkbox',...
                'String', 'Use Video',...
                'Value', 0,...
                'Callback', @obj.onCheckVideo);
            uicontrol(uiLayout,...
                'Style', 'push', 'String', 'Export',...
                'Callback', @obj.onPushExport);
            
            set(plotLayout, 'Widths', [-3, -1]);
            set(mainLayout, 'Heights', [-0.5, -12, -1]);

        end
    end
end 