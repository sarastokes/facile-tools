classdef ConeGainView < handle 

    properties
        dataset(1,1) %ao.core.DatasetLED2
        stimuli(1,3) ao.SpectralStimuli 
        calibration(1,1) %ConeIsolation
        stimValues(1,:) double
        bkgdValue(1,1) double 

        RData 
        GData 
        BData
        XData(1,:) double 

        TR
        TG
        TB

        QCatch(3,3,:) double 
    end

    properties
        currentRoi(1,1) double = 1
        currentValue(1,1) double = 4

        onResp(3,:) double 
        offResp(3,:) double 
        onGain(3,:) double 
        offGain(3,:) double 
        ratios(3,:) double 

        onRespAll(3,:,:) double 
        offRespAll(3,:,:) double
        onGainAll(3,:,:) double 
        offGainAll(3,:,:) double 
        ratiosAll(3,:,:) double 
    end

    properties 
        figureHandle(1,1) matlab.ui.Figure 
        onRespAxis(1,1) matlab.ui.control.UIAxes
        offRespAxis(1,1) matlab.ui.control.UIAxes
        onConeAxis(1,1) matlab.ui.control.UIAxes
        offConeAxis(1,1) matlab.ui.control.UIAxes
        ratioAxis(1,1) matlab.ui.control.UIAxes
        respAxis(1,1) matlab.ui.control.UIAxes
        barAxis(1,1) matlab.ui.control.UIAxes
        roiLabel%(1,1) matlab.ui.control.UILabel 

        onRespLines(1,3) matlab.graphics.primitive.Line
        offRespLines(1,3) matlab.graphics.primitive.Line
        onConeLines(1,3) matlab.graphics.primitive.Line
        offConeLines(1,3) matlab.graphics.primitive.Line
        ratioLines(1,3) matlab.graphics.primitive.Line   
        respLines(1,3) matlab.graphics.primitive.Line
        coneBar(1,1) matlab.graphics.chart.primitive.Bar
    end

    properties
        showPopulation(1,1) logical = false
        populationFigure%(1,1) matlab.ui.Figure 
        populationAxes%(1,1) matlab.ui.control.UIAxes
        populationLine(1,1) matlab.graphics.primitive.Line
    end

    properties (Dependent,  Hidden)
        numRois 
        numValues
    end

    properties (Constant, Hidden)
        COLORS = [1 0.3 0.3; 0.3 1 0.3; 0.3 0.3 1];
    end


    methods
        function obj = ConeGainView(dataset, stimulusNames, stimValues, bkgdValue, varargin)
            obj.dataset = dataset;
            obj.stimValues = stimValues;
            obj.bkgdValue = bkgdValue;
            obj.calibration = obj.dataset.getCalibration('LEDs');

            if isstring(stimulusNames)
                stimuli = [];
                for i = 1:numel(stimulusNames)
                    stimuli = cat(2, stimuli, ao.SpectralStimuli.init(stimulusNames(i)));
                end
            end
            obj.stimuli = stimuli;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'TR', [], @istable);
            addParameter(ip, 'TG', [], @istable);
            addParameter(ip, 'TB', [], @istable);
            parse(ip, varargin{:});
            obj.TR = ip.Results.TR;
            obj.TG = ip.Results.TG;
            obj.TB = ip.Results.TB;

            % Preallocate
            obj.onRespAll = zeros(3, obj.numValues, obj.numRois);
            obj.offRespAll = zeros(3, obj.numValues, obj.numRois);
            obj.onGainAll = zeros(3, obj.numValues, obj.numRois);
            obj.offGainAll = zeros(3, obj.numValues, obj.numRois);
            obj.ratiosAll = zeros(3, obj.numValues, obj.numRois);

            obj.doAnalysis();
            obj.createUi();
        end

        function value = get.numRois(obj)
            value = obj.dataset.numROIs;
        end
        
        function value = get.numValues(obj)
            value = numel(obj.stimValues);
        end
    end

    % Update methods
    methods (Access = private)
        function updateView(obj)
            obj.updateAnalysis();
            if obj.showPopulation
                obj.updatePopulation();
            end

            for i = 1:3
                set(obj.onRespLines(i), 'YData', obj.onResp(i,:));
                set(obj.offRespLines(i), 'YData', obj.offResp(i,:));
                set(obj.onConeLines(i), 'YData', obj.onGain(i,:));
                set(obj.offConeLines(i), 'YData', obj.offGain(i,:));
                set(obj.ratioLines(i), 'YData', obj.ratios(i,:));
            end
            set(obj.respLines(1), 'YData', obj.RData(obj.currentRoi,:));
            set(obj.respLines(2), 'YData', obj.GData(obj.currentRoi,:));
            set(obj.respLines(3), 'YData', obj.BData(obj.currentRoi,:));

            obj.coneBar.YData = obj.ratios(:, obj.currentValue)';

            [s, l] = bounds([obj.onResp; obj.offResp], 'all', 'omitnan');
            if s == l
                l = s + 1;
            end
            ylim(obj.onRespAxis, [floor(s), ceil(l)]);
            xlim(obj.respAxis, [0, max(obj.XData)]);

            obj.roiLabel.Text = sprintf('Roi %u of %u', obj.currentRoi, obj.numRois);
            title(obj.barAxis, sprintf('LMS %u of %u', obj.currentValue, obj.numValues));
        end

        function updateAnalysis(obj)
            % UPDATEANALYSIS

            % if nnz(obj.onRespAll(:,:,roiID)) > 0 || nnz(obj.offRespAll(:,:,roiID)) > 0
            %     obj.onGain = obj.onGainAll(:,:,roiID);
            %     obj.offGain = obj.offGainAll(:,:,roiID);
            %     obj.onResp = obj.onRespAll(:,:,roiID);
            %     obj.offResp = obj.offRespAll(:,:,roiID);
            %     obj.ratios = obj.ratiosAll(:,:,roiID);
            %     return
            % end

            % Analysis functions
            getRoiOnResp = @(roiID, intID) [...
                obj.TR.onset(roiID, intID)^2,... 
                obj.TG.onset(roiID, intID)^2, ...
                obj.TB.onset(roiID,intID)^2]';
            getRoiOffResp = @(roiID, intID) [...
                obj.TR.offset(roiID, intID)^2, ...
                obj.TG.offset(roiID, intID)^2, ...
                obj.TB.offset(roiID,intID)^2]';
            getRoiConeGain = @(data, intID) obj.QCatch(:,:,intID)'\abs(data);

            for i = 1:numel(obj.stimValues)
                obj.onResp(:,i) = getRoiOnResp(obj.currentRoi, i);
                obj.offResp(:,i) = getRoiOffResp(obj.currentRoi, i);
            end
            obj.onResp(obj.onResp < 0.02) = 0;
            obj.offResp(obj.offResp < 0.02) = 0;

            for i = 1:numel(obj.stimValues)
                obj.onGain(:, i) = getRoiConeGain(obj.onResp(:,i), i);
                obj.offGain(:, i) = getRoiConeGain(obj.offResp(:,i), i);
            end
            obj.onGain = obj.onGain ./ sum(abs([obj.onGain; obj.offGain]), 1, 'omitnan');
            obj.offGain = obj.offGain ./ sum(abs([obj.onGain; obj.offGain]), 1, 'omitnan');
            obj.onGain(isnan(obj.onGain)) = 0;
            obj.offGain(isnan(obj.offGain)) = 0;

            for i = 1:numel(obj.stimValues)
                obj.ratios(:,i) = (obj.onGain(:,i) - obj.offGain(:,i)) ./ (abs(obj.onGain(:,i)) + abs(obj.offGain(:,i)));
                for j = 1:3
                    if isnan(obj.ratios(j,i))
                        % Set all NaNs to zero
                        obj.ratios(j,i) = 0;
                    else
                        % Weight by the max weight to avoid amplifying noise
                        obj.ratios(j,i) = obj.ratios(j,i) * max(abs([obj.onGain(j,i), obj.offGain(j,i)]));
                    end
                end
            end

            obj.onGainAll(:,:,obj.currentRoi) = obj.onGain;
            obj.offGainAll(:,:,obj.currentRoi) = obj.offGain;
            obj.onRespAll(:,:,obj.currentRoi) = obj.onResp;
            obj.offRespAll(:,:,obj.currentRoi) = obj.offResp;
            obj.ratiosAll(:,:,obj.currentRoi) = obj.ratios;
        end

        function updatePopulation(obj)
            iRatios = squeeze(obj.ratiosAll(:,obj.currentValue,:));
            iRatios = iRatios ./ squeeze(sum(abs(obj.ratiosAll(:,obj.currentValue,:)), 1))';

            set(obj.populationLine, ...
                'XData', iRatios(1, :), ...
                'YData', iRatios(2, :));
        end
    end

    % Initialization methods
    methods (Access = private)
        function doAnalysis(obj)
            % RESPONSES
            disp('Loading responses...');
            dataProps = {'HighPass', 0.005, 'Smooth', 100};
            [obj.RData, obj.XData] = obj.dataset.getStimulusResponses(...
                obj.stimuli(1), [250 498], 'Average', true, dataProps{:});
            obj.GData = obj.dataset.getStimulusResponses(...
                obj.stimuli(2), [250 498], 'Average', true, dataProps{:});
            obj.BData = obj.dataset.getStimulusResponses(...
                obj.stimuli(3), [250 498], 'Average', true, dataProps{:});

            disp('Calculating statistics...')
            if isempty(obj.TR)
                obj.TR = getPulseStats(obj.dataset, obj.stimuli(1), dataProps{:});
            end
            if isempty(obj.TG)
                obj.TG = getPulseStats(obj.dataset, obj.stimuli(2), dataProps{:});
            end
            if isempty(obj.TB)
                obj.TB = getPulseStats(obj.dataset, obj.stimuli(3), dataProps{:});
            end

            % CALIBRATIONS       
            disp('Calibrating stimuli...') 
            h = 6.626e-34;              % Joules/sec
            c = 3.0e8;                  % meters/sec
            outerSegment = 0.6;         % um2
            quantalEfficiency = 0.37;   

            % Convert wavelength from nm to meters
            lambda = obj.calibration.wavelengths * 1e-9;
            % Divide by the wavelength to get the energy in watts/sec
            quantalSpectra = 1e-9 * obj.calibration.primaries .* (lambda*ones(1,3)) / (h*c);
            
            % Apply to the cone spectral sensitivities
            photonFlux = (quantalSpectra' * obj.calibration.receptors(1:3,:)');
            qCatch = photonFlux * outerSegment;

            % Factor in quantal efficiency
            qCatch = qCatch * quantalEfficiency;
            qCatch(qCatch < 0) = 0;

            % Normalize across primaries
            pEffic = zeros(3,3);
            for i = 1:3
                pEffic(i,:) = qCatch(i,:) / max(qCatch(:));
            end

            % Raw LED weights
            maxBkgd = 2 * obj.calibration.ledBkgd;
            W = obj.stimValues .* maxBkgd ./ obj.calibration.ledPowers';
            dW = W - (obj.bkgdValue * maxBkgd ./ obj.calibration.ledPowers');
            
            % Quantal catch per value
            obj.QCatch = zeros(3,3,numel(obj.stimValues));
            for i = 1:numel(obj.stimValues)
                obj.QCatch(:,:,i) = pEffic .* dW(:,i);
            end
        end

        function createUi(obj)
            disp('Creating user interface...');
            axProps = {'XGrid', 'on', 'YGrid', 'on'};
            rLineProps = {'Marker', 'o', 'LineWidth', 1, 'Color', obj.COLORS(1,:)};
            gLineProps = {'Marker', 'o', 'LineWidth', 1, 'Color', obj.COLORS(2,:)};
            bLineProps = {'Marker', 'o', 'LineWidth', 1, 'Color', obj.COLORS(3,:)};

            obj.figureHandle = uifigure(...
                'KeyPressFcn', @obj.onKeyPress);
            
            g = uigridlayout(obj.figureHandle, [3 4],...
                'RowHeight', {30, '1x', '1x'});

            obj.roiLabel = uilabel(g,...
                'HorizontalAlignment', 'center');
            obj.roiLabel.Layout.Column = [1 4];
            obj.roiLabel.Layout.Row = 1;

            obj.onRespAxis = uiaxes(g, axProps{:});
            obj.onRespAxis.Layout.Column = 1;
            obj.onRespAxis.Layout.Row = 2;
            title(obj.onRespAxis, 'ON Response');
            obj.onRespLines(1) = line(obj.onRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), rLineProps{:});
            obj.onRespLines(2) = line(obj.onRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), gLineProps{:});
            obj.onRespLines(3) = line(obj.onRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), bLineProps{:});

            obj.offRespAxis = uiaxes(g, axProps{:});
            obj.offRespAxis.Layout.Column = 1;
            obj.offRespAxis.Layout.Row = 3;
            hold(obj.offRespAxis, 'on');
            title(obj.offRespAxis, 'OFF Response');
            obj.offRespLines(1) = line(obj.offRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), rLineProps{:});
            obj.offRespLines(2) = line(obj.offRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), gLineProps{:});
            obj.offRespLines(3) = line(obj.offRespAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), bLineProps{:});

            obj.onConeAxis = uiaxes(g, axProps{:});
            obj.onConeAxis.Layout.Column = 2;
            obj.onConeAxis.Layout.Row = 2;
            title(obj.onConeAxis, 'ON Cones');
            obj.onConeLines(1) = line(obj.onConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), rLineProps{:});
            obj.onConeLines(2) = line(obj.onConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), gLineProps{:});
            obj.onConeLines(3) = line(obj.onConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), bLineProps{:});

            obj.offConeAxis = uiaxes(g, axProps{:});
            obj.offConeAxis.Layout.Column = 2;
            obj.offConeAxis.Layout.Row = 3;
            title(obj.offConeAxis, 'OFF Cones');
            obj.offConeLines(1) = line(obj.offConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), rLineProps{:});
            obj.offConeLines(2) = line(obj.offConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), gLineProps{:});
            obj.offConeLines(3) = line(obj.offConeAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), bLineProps{:});

            obj.ratioAxis = uiaxes(g, axProps{:});
            obj.ratioAxis.Layout.Column = 3;
            obj.ratioAxis.Layout.Row = 2;
            title(obj.ratioAxis, 'Relative Cones');
            obj.ratioLines(1) = line(obj.ratioAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), rLineProps{:});
            obj.ratioLines(2) = line(obj.ratioAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), gLineProps{:});
            obj.ratioLines(3) = line(obj.ratioAxis,...
                obj.stimValues, NaN(1, numel(obj.stimValues)), bLineProps{:});
            
            obj.barAxis = uiaxes(g);
            obj.barAxis.Layout.Column = 4;
            obj.barAxis.Layout.Row = 2;
            title(obj.barAxis, sprintf('LMS %u of %u',... 
                obj.currentValue, numel(obj.stimValues)));
            obj.coneBar = bar(obj.barAxis, 1:3, NaN(1,3),... 
                'FaceColor', 'flat', 'CData', obj.COLORS);
            set(obj.barAxis, 'XTickLabels', {'L','M','S'});
            ylim(obj.barAxis, [-1 1]);
            
            obj.respAxis = uiaxes(g, axProps{:});
            obj.respAxis.Layout.Column = 3:4;
            obj.respAxis.Layout.Row = 3;
            hold(obj.respAxis, 'on');
            title(obj.respAxis, 'Data');
            axis(obj.respAxis, 'tight');
            obj.respLines(1) = line(obj.respAxis,...
                obj.XData, obj.RData(1,:),... 
                'Color', obj.COLORS(1,:), 'LineWidth', 0.8);
            obj.respLines(2) = line(obj.respAxis,...
                obj.XData, obj.GData(1,:), ... 
                'Color', obj.COLORS(2,:), 'LineWidth', 0.8);
            obj.respLines(3) = line(obj.respAxis,...
                obj.XData, obj.BData(1,:),... 
                'Color', obj.COLORS(3,:), 'LineWidth', 0.8);

            % Axes limits and other presets
            linkaxes([obj.onRespAxis, obj.offRespAxis]);
            ylim([obj.onConeAxis, obj.offConeAxis, obj.ratioAxis], [-1 1]);
            xlim(obj.getAllAxes(),...
                [floor(min(obj.stimValues)), ceil(max(obj.stimValues))]);
            hold(obj.getAllAxes(), 'on');
            obj.updateView();
        end

        function createPopulationFigure(obj)
            lineProps = {'Color', [0.5 0.5 0.5], 'LineWidth', 1};
            obj.populationFigure = figure();
            obj.populationAxes = axes('Parent', obj.populationFigure);
            hold(obj.populationAxes, 'on');
            plot(obj.populationAxes, [1 0 -1 0 1], [0 -1 0 1 0], lineProps{:});
            plot(obj.populationAxes, [-1 1], [0 0], lineProps{:});
            plot(obj.populationAxes, [0 0], [-1 1], lineProps{:});
            obj.populationLine = line(obj.populationAxes, NaN, NaN, ...
                'Color', 'k', 'LineStyle', 'none', 'Marker', 'o',... 
                'MarkerSize', 5, 'LineWidth', 1);
            xlim(obj.populationAxes, [-1.01 1.01]);
            ylim(obj.populationAxes, [-1.01 1.01]);
            axis(obj.populationAxes, 'square');
            figPos(obj.populationFigure, 0.6, 0.6);
        end
    end
    
    % Callback methods
    methods (Access = private)
        function ax = getAllAxes(obj)
            ax = [obj.onRespAxis, obj.offRespAxis, obj.onConeAxis, ...
                obj.offConeAxis, obj.ratioAxis, obj.respAxis];
        end

        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'leftarrow'
                    if obj.currentRoi == 1
                        return;
                    end
                    obj.currentRoi = obj.currentRoi - 1;
                    obj.updateView();
                case 'rightarrow'
                    obj.currentRoi = obj.currentRoi + 1;
                    obj.updateView();
                case 'uparrow'
                    if obj.currentValue == numel(obj.stimValues)
                        return
                    end
                    obj.currentValue = obj.currentValue + 1;
                    obj.updateView();
                case 'downarrow'
                    if obj.currentValue == 1
                        return
                    end
                    obj.currentValue = obj.currentValue - 1;
                    obj.updateView();
                case 'p'
                    if ~obj.showPopulation
                        obj.createPopulationFigure();
                        obj.showPopulation = true;
                    else
                        delete(obj.populationFigure);
                        obj.showPopulation = true;
                    end
            end
        end
    end
end 