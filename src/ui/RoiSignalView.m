classdef RoiSignalView < handle

    properties (SetAccess = private)
        imStack
        roiMask
        sampleRate 
    end

    properties %(Access = private)
        responseType
        bkgdWindow
        signalWindow
        
        avgImage
        currentRoi
        totalRois
        figureHandle
        roiAxis
        roiHandle
        signalHandle
    end

    methods 
        function obj = RoiSignalView(imStack, roiMask, sampleRate, varargin)
                       
            obj.imStack = imStack;
            obj.roiMask = roiMask;
            obj.sampleRate = sampleRate;
            
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Title', [], @ischar);
            addParameter(ip, 'Bkgd', [], @isnumeric);
            addParameter(ip, 'Signal', [], @isnumeric);
            parse(ip, varargin{:});

            obj.bkgdWindow = ip.Results.Bkgd;
            obj.signalWindow = ip.Results.Signal;
            
            obj.responseType = 'raw';

            obj.currentRoi = 1;
            obj.totalRois = numel(unique(obj.roiMask)) - 1;
            obj.avgImage = squeeze(mean(obj.imStack, 3));

            obj.createUi(ip.Results.Title);
        end
        
    end

    methods (Access = private)
        function changeRoi(obj)

            mask = obj.roiMask == obj.currentRoi;
            set(obj.roiHandle, 'CData', mask, 'AlphaData', 0.3 * mask);
            
            [response, xpts] = roiSignal(obj.imStack, mask, obj.sampleRate);
            % If signal/bkgd are specified, calculate those
            if ~isempty(obj.bkgdWindow) && ~isempty(obj.signalWindow)
                bkgd = mean(response(obj.bkgdWindow(1):obj.bkgdWindow(2)));
                signal = mean(response(obj.signalWindow(1):obj.signalWindow(2)));
                
                % Check if signal is over 2 SDs away from bkgd mean 
                thresh = 2 * std(response(obj.bkgdWindow(1):obj.bkgdWindow(2)));
                if signal >= thresh || signal <= thresh
                    fw = 'bold';
                else
                    fw = 'normal';
                end
                
                % Display signal and background 
                set(findobj(obj.figureHandle, 'Tag', 'SignalValue'),...
                    'String', sprintf('%.3f', signal),...
                    'FontWeight', fw);
                set(findobj(obj.figureHandle, 'Tag', 'BkgdValue'),...
                    'String', sprintf('%.3f', bkgd));
                                
                % Get dF/F if needed
                if contains(obj.responseType, 'dff')
                    response = (response - bkgd) ./ bkgd;
                end   
                if contains(obj.responseType, 'dff_median')
                    %response = response - median(response(20:64));
                end
                
                if strcmp(obj.responseType, 'dff_median_hp')
                    % newXpts = linspace(xpts(1), xpts(end), 4*numel(xpts));
                    % newXpts = xpts(1):(0.25 * (xpts(2)-xpts(1))):xpts(end);
                    % response = interp(xpts, response, newXpts);
                    response = lowPassFilter(response, 1.25, xpts(2) - xpts(1))';
                end
            end
                        
            h = findobj(obj.figureHandle, 'Tag', 'Smooth');
            if ~isempty(h.String) && ~strcmp(h.String, '1')
                smoothFac = str2double(h.String);
                response = padarray(response, [smoothFac, 0], 0, 'both');
                response = smooth(response, smoothFac);
                response(1:smoothFac) = [];
                response(end-smoothFac+1:end) = [];
            end
            
            set(obj.signalHandle, 'YData', response);
            set(findByTag(obj.figureHandle, 'CurrentRoi'),...
                'String', sprintf('ROI = %u', obj.currentRoi));
            ylim(obj.signalHandle.Parent, [-max(abs(response)), max(abs(response))]);
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)          
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
            if obj.currentRoi < 1
                obj.currentRoi = 1;
            elseif obj.currentRoi > obj.totalRois
                obj.currentRoi = obj.totalRois;
            end

            obj.changeRoi()
        end
        
        function onEdit_Smooth(obj, ~, ~)
            obj.changeRoi();
        end
        
        function onEdit_ROI(obj, src, ~)
            try
                newRoi = str2double(src.String);
                set(src, 'ForegroundColor', 'k');
            catch
                set(src, 'ForegroundColor', 'r');
            end
            obj.currentRoi = newRoi;
            obj.changeRoi();
            set(src, 'String', '');
        end
        
        function onChanged_ResponseType(obj, src, ~)
            if src.Value ~= 1 && isempty(obj.bkgdWindow)
                set(src, 'Value', 1);
            end
            
            obj.responseType = src.String{src.Value};
            switch obj.responseType
                case 'raw'
                    ylabel(obj.signalHandle.Parent, 'Response (F)');
                otherwise
                    ylabel(obj.signalHandle.Parent', 'Response (dF/F)');
            end
            obj.changeRoi();
        end
        
        function onPush_ApplyWindows(obj, ~, ~)
            names = {'BkgdStart', 'BkgdStop', 'SignalStart', 'SignalStop'};
            values = zeros(1, 4);
            for i = 1:numel(names)
                h = findobj(obj.figureHandle, 'Tag', names{i});
                values(i) = str2double(h.String);
                set(h, 'ForegroundColor', [0, 0.7, 0.3]);
            end
            
            obj.bkgdWindow = values(1:2);
            obj.signalWindow = values(3:4);
        end
        
        function onEdit_NumberBox(~, src, ~)
            try
                x = str2double(src.Value);
                set(src, 'ForegroundColor', 'k');
            catch
                set(src, 'ForegroundColor', 'r');
            end
        end
    end

    methods (Access = private)

        function createUi(obj, titleStr)
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
            if ~isempty(titleStr)
                uicontrol(uiLayout, 'Style', 'text', 'String', titleStr);
            end
            uicontrol(uiLayout, 'Style', 'text', 'String', 'ROI = 1',...
                'Tag', 'CurrentRoi');
            uicontrol(uiLayout, 'Style', 'text',...
                'String', sprintf('Total = %u', obj.totalRois));
            
            g = uix.Grid('Parent', uiLayout,...
                'BackgroundColor', 'w');
            uicontrol(g, 'Style', 'text', 'String', 'ROI:');
            uicontrol(g, 'Style', 'text', 'String', 'Smooth:');
            uicontrol(g, 'Style', 'edit', 'String', '',... 
                'Callback', @obj.onEdit_ROI);
            uicontrol(g, 'Style', 'edit', 'String', '1', 'Tag', 'Smooth',...
                'Callback', @obj.onEdit_Smooth);
            set(g, 'Heights', [-1 -1], 'Widths', [-1 -1]);
            
            uicontrol(uiLayout,...
                'Style', 'popup',...
                'String', {'raw', 'dff', 'dff_median', 'dff_median_hp'},...
                'Callback', @obj.onChanged_ResponseType);

            % Bkgd/Signal control
            g = uix.Grid('Parent', uiLayout, 'BackgroundColor', 'w');

            uix.Empty('Parent', g, 'BackgroundColor', 'w');
            uicontrol(g, 'Style', 'text', 'String', 'Bkgd');
            uicontrol(g, 'Style', 'text', 'String', 'Signal');

            uicontrol(g, 'Style', 'text', 'String', 'Start');
            b1 = uicontrol(g, 'Style', 'edit', 'Tag', 'BkgdStart',...
                'Callback', @obj.onEdit_NumberBox); 
            s1 = uicontrol(g, 'Style', 'edit', 'Tag', 'SignalStart',...
                'Callback', @obj.onEdit_NumberBox);  

            uicontrol(g, 'Style', 'text', 'String', 'Stop');
            b2 = uicontrol(g, 'Style', 'edit', 'Tag', 'BkgdStop',...
                'Callback', @obj.onEdit_NumberBox);  
            s2 = uicontrol(g, 'Style', 'edit', 'Tag', 'SignalStop',...
                'Callback', @obj.onEdit_NumberBox);  
            
            if ~isempty(obj.bkgdWindow)
                set(b1, 'String', num2str(obj.bkgdWindow(1)));
                set(b2, 'String', num2str(obj.bkgdWindow(2)));
            end

            if ~isempty(obj.signalWindow)
                set(s1, 'String', num2str(obj.signalWindow(1)));
                set(s2, 'String', num2str(obj.signalWindow(2)));
            end
            
            uicontrol(g, 'Style', 'text', 'String', 'Value');
            uicontrol(g, 'Style', 'text', 'Tag', 'BkgdValue');
            uicontrol(g, 'Style', 'text', 'Tag', 'SignalValue');
            
            set(g, 'Heights', [-1 -1 -1], 'Widths', [-1 -1 -1 -1]);
            
            uicontrol(uiLayout, 'Style', 'push', 'String', 'Apply',...
                'Callback', @obj.onPush_ApplyWindows);
            
            % Roi display
            obj.roiAxis = axes(uipanel(roiLayout, 'BackgroundColor', 'w'));
            obj.roiHandle = roiOverlay(obj.avgImage, obj.roiMask == obj.currentRoi,... 
                'Colormap', 'pink', 'Parent', obj.roiAxis);
            
            % Signal display
            [signal, xpts] = roiSignal(obj.imStack,... 
                obj.roiMask == obj.currentRoi, obj.sampleRate);

            ax2 = axes(uipanel(mainLayout, 'BackgroundColor', 'w'));
            hold(ax2, 'on');
            plot(ax2, [xpts(1), xpts(end)], [0, 0], 'Color', 'k');
            obj.signalHandle = line(ax2, xpts, signal,... 
                'Color', rgb('navy'), 'LineWidth', 1.5);
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