classdef ResponseArrayApp < handle
    
    properties
        data
        X
        
        figureHandle
        lineHandle
        axHandle
        currentTrace
    end
    
    methods 
        function obj = ResponseArrayApp(data, varargin)
            obj.data = squeeze(data);
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'X', 1:size(data, 2), @isvector); 
            parse(ip, varargin{:});
            
            obj.X = ip.Results.X;
            assert(numel(obj.X) == size(data, 2),...
                'Elements in X should match # of columns in data array');
            
            obj.currentTrace = 1;
            
            obj.createUi(ip.Unmatched);
        end
    end
    
    methods (Access = private)
        function onKeyPress(obj, ~, event)
            switch event.Key
                case 'rightarrow'
                    obj.nextTrace();
                case 'leftarrow'
                    obj.previousTrace();
            end
        end
        
        function nextTrace(obj)
            if obj.currentTrace == size(obj.data, 1)
                return;
            end
            obj.currentTrace = obj.currentTrace + 1;
            obj.updateData();
        end
        
        function previousTrace(obj)
            if obj.currentTrace == 1
                return
            end
            obj.currentTrace = obj.currentTrace - 1;
            obj.updateData();
        end
        
        function updateData(obj)
            set(obj.lineHandle, 'YData', obj.data(obj.currentTrace, :));
            set(findobj(obj.figureHandle, 'Tag', 'StatusBox'),...
                'String', sprintf('%u of %u', obj.currentTrace, size(obj.data, 1)));
        end
    end
    
    methods (Access = private)
        function createUi(obj, varargin)
            obj.figureHandle = figure(...
                'DefaultUiControlFontName', 'Arial',...
                'DefaultUiControlFontSize', 10,...
                'DefaultUiControlBackgroundColor', 'w',...
                'KeyPressFcn', @obj.onKeyPress,...
                'Color', 'w');
            
            mainLayout = uix.VBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            uicontrol(mainLayout, 'Style', 'text', 'Tag', 'StatusBox',...
                'String', sprintf('Trace 1 of %u', size(obj.data, 1)));
            p = uipanel(mainLayout, 'BackgroundColor', 'w');
            obj.axHandle = axes('Parent', p);
            hold(obj.axHandle, 'on');
            line(obj.axHandle, 0, 0); 
            obj.lineHandle = line(obj.X, obj.data(1, :),...
                'Parent', obj.axHandle, varargin{:});
            
            set(mainLayout, 'Heights', [30, -1]);
        end
    end
end