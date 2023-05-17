classdef ExperimentHome < handle
% EXPERIMENTHOME
%
% Description:
%   UI to access different stimuli contained within a Dataset.
%
% Constructor:
%   ExperimentHome(Dataset)
% 
% History:
%   13Dec2020 - SSP
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Dataset
    end

    properties (Hidden, Access = private)
        figureHandle
    end

    methods 
        function obj = ExperimentHome(data)

            obj.Dataset = data;

            obj.createUi();
        end
    end

    methods (Access = private)
        function onClick_Go(obj, src, ~)
            stim = obj.Dataset.stim{str2double(src.Tag), 3};
            app = stim.openRoiAverageView(obj.Dataset);
            app.setTitle([char(obj.Dataset.experimentDate), ' ', char(stim)]);
        end
        
        function onClick_Export(obj, src, ~)
            epochIDs = obj.Dataset.stim{str2double(src.Tag), 4};
            epochIDs = epochIDs{1};
            stim = obj.Dataset.stim{str2double(src.Tag), 3};

            [signals, xpts] = obj.Dataset.getEpochResponses(epochIDs, stim.bkgd);

            assignin('base', 'signals', signals);
            assignin('base', 'xpts', xpts);
            fprintf('Assigned to variables ''signals'' and ''xpts''\n');
        end
    end

    methods (Access = private)
        function createUi(obj)
            titleStr = [num2str(double(obj.Dataset.source)), '_',... 
                char(obj.Dataset.experimentDate), ' - ',... 
                num2str(obj.Dataset.numROIs), ' ROIs'];
            obj.figureHandle = figure(...
                'Name', titleStr,...
                'Color', 'w', ...
                'NumberTitle', 'off', ...
                'DefaultUicontrolBackgroundColor', 'w', ...
                'DefaultUicontrolFontName', 'Arial', ...
                'DefaultUicontrolFontSize', 10, ...
                'Toolbar', 'none', ...
                'Menubar', 'none');
            
            mainLayout = uix.HBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            g = uix.Grid('Parent', mainLayout,...
                'BackgroundColor', 'w');
            
            stim = obj.Dataset.stim;
            
            for i = 1:height(stim)
                uicontrol(g, 'Style', 'text',...
                    'String', i);
            end

            for i = 1:height(stim)
                uicontrol(g, 'Style', 'text',... 
                    'String', char(stim{i, 3}),...
                    'FontSize', 8);
            end

            for i = 1:height(stim)
                uicontrol(g, 'Style', 'text',... 
                    'String', num2str(stim{i, 2}));
            end

            for i = 1:height(stim)
                uicontrol(g, 'Style', 'push', 'String', 'Go!',...
                    'Tag', num2str(stim{i, 1}),... 
                    'Callback', @obj.onClick_Go);
            end
            
            for i = 1:height(stim)
                uicontrol(g, 'Style', 'push', 'String', 'Export',...
                    'Tag', num2str(stim{i, 1}),... 
                    'Callback', @obj.onClick_Export);
            end

            set(g, 'Widths', [-0.5 -4 -1 -1 -1],... 
                'Heights', -1 * ones(1, height(stim)));
            obj.figureHandle.Position(3) = 0.7 * obj.figureHandle.Position(3);
            obj.figureHandle.Position(4) = 22.5 * height(stim);
        end
    end
end