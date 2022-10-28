classdef StimTrace < handle

    properties (SetAccess = private)
        xpts
        data
        axHandle
        parentHandle

        stimWindow
  
        epochIDs
        colorOrder
        stimPatch 
    end

    methods 
        function obj = StimTrace(xpts, data, axHandle, parentHandle, varargin)
            obj.xpts = xpts;
            obj.data = data;
            obj.axHandle = axHandle;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'StimWindow', [], @isnumeric);
            parse(ip, varargin{:});
            obj.stimWindow = ip.Results.StimWindow;

            if nargin < 5
                stimWindow = [];
            end

            obj.epochIDs = size(data, 3);
            if numel(obj.epochIDs) > 1
                obj.colorOrder = pmkmp(numel(epochIDs), 'CubicL');
            else
                obj.colorOrder = [0, 0, 0.3];
            end

            obj.addParent(parentHandle);
        end

        function addParent(obj, parentHandle)
            obj.parentHandle = parentHandle;

            obj.initializePlot(obj.parentHandle.currentRoi);

            addListener(obj.parentHandle, 'ChangedROI',...
                @(src, evt) obj.onAppChangedROI);
        end
    end

    methods (Access = private)
        function onAppChangedROI(obj, src, evt)
            obj.updatePlot(obj.parentHandle.currentRoi);
        end
    end
    
    methods
        function updatePlot(obj, currentRoi)
            [roiData, roiAvg] = obj.getRoiSignal(currentRoi);

            delete(findall(obj.axHandle, 'Tag', 'SignalLine'));
            for i = 1:size(roiData, 2)
                plot(obj.axHandle, obj.xpts, roiData(:, i),...
                    'Color', co(i,:), 'LineWidth', 0.55,... 
                    'Tag', 'SignalLine');
            end
            plot(obj.axHandle, obj.xpts, roiAvg,...
                'Color', [0.1 0.1 0.1], 'LineWidth', 0.9,... 
                'Tag', 'AvgLine');
            
            % Set the y-axis scaling
            maxVal = max(max(abs(roiData), [], 'omitnan'), [], 'omitnan');
            maxVal = ceil(maxVal);
            if ~isempty(obj.stimPatch)
                obj.stimPatch.YData = maxVal * [1 1 -1 -1];
            end
            ylim(obj.axHandle, [-maxVal, maxVal]);
            drawnow;
        end

        function [signal, avgSignal] = getRoiSignal(obj, currentRoi)
            roiData = squeeze(obj.data(currentRoi, :, :));

            smoothFac = obj.parentHandle.smoothFac;

            if ~isempty(smoothFac) && smoothFac > 1
                for i = 1:size(roiData, 2)
                    roiData(:, i) = mysmooth(roiData(:, i), smoothFac);
                end
            end

            if obj.parentHandle.doNorm 
                stimStartFrame = obj.parentHandle.stimWindow(1) / (1 / obj.parentHandle.Dataset.frameRate);
                roiData = bsxfun(@minus, roiData,...
                    median(allSignals(smoothFac+1 : stimStartFrame), :), 1));
            end

            avgSignal = nanmean(roiData, 2);
        end


        function initializePlot(obj, stimWindow)
            hold(obj.axHandle, 'on');
            plot(obj.axHandle, [obj.xpts(1), obj.xpts(end)], [0 0],...
                'Color', [0.4, 0.4, 0.4]);

            grid(obj.axHandle, 'on');
            xlabel(obj.axHandle, 'Time (sec)');
            ylabel(obj.axHandle, 'Signal (dF/F)');

            if ~isempty(stimWindow)
                obj.stimPatch = patch(...
                    'XData', [stimWindow, fliplr(stimWindow)],... 
                    'YData', [1 1 -1 -1],...
                    'Parent', obj.axHandle,... 
                    'FaceColor', [0.3 0.3 1],... 
                    'FaceAlpha', 0.15,... 
                    'EdgeColor', 'none',...
                    'Tag', 'StimPatch');
            end

            obj.updateSignalPlot(1);
        end
    end
end 