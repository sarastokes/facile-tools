classdef ClusterStimulus < handle 

    properties 
        signals 
        rawSignals
        xpts 
        bounds 
        endStop
        startPt
        roiList 
        padding
        normalizeF 

        nComp 
        nNonZero
        smoothFac 
        dsampFac
        badRois 

        threshR 
        threshQI   
        threshMotion
        
        stimWindows 
    end


    properties (SetAccess = private)
        f 
        b
        v 
        QI 
        avgData 

        clust
        clustAvg1 
        clustN1

        clustAvg2 
        clustN2 
        
        hasMerged
    end

    properties (Dependent = true)
        numClusters
        numFeatures
        clustAvg 
        clustIdx
        clustN 
        roiFinder 
        badRoiIDs
    end

    properties (Hidden, Dependent = true)
        fRange
        sigma
    end

    properties (Hidden, Constant)
        QI_SIGMA = 100;
    end

    methods 
        function obj = ClusterStimulus(signals, bounds, nComp, nNonZero, varargin)

            obj.signals = signals;
            obj.nComp = nComp;
            obj.nNonZero = nNonZero;
            obj.bounds = bounds;

            % Optional parameters
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'ThreshQI', 1, @isnumeric);
            addParameter(ip, 'SmoothFac', 100, @isnumeric);
            addParameter(ip, 'StimWindows', obj.bounds, @isnumeric);
            addParameter(ip, 'ThreshR', 0.9, @isnumeric);
            addParameter(ip, 'RawSignals', [], @isnumeric);
            addParameter(ip, 'Padding', 20, @isnumeric);
            addParameter(ip, 'EndStop', [], @isnumeric);
            addParameter(ip, 'StartPt', [], @isnumeric);
            addParameter(ip, 'ThreshMotion', 0.008, @isnumeric);
            addParameter(ip, 'NormalizeF', false, @islogical);
            addParameter(ip, 'DsampFac', [], @isnumeric);
            parse(ip, varargin{:});

            obj.smoothFac = ip.Results.SmoothFac;
            obj.stimWindows = ip.Results.StimWindows;
            obj.threshQI = ip.Results.ThreshQI;
            obj.threshR = ip.Results.ThreshR;
            obj.threshMotion = ip.Results.ThreshMotion;
            obj.rawSignals = ip.Results.RawSignals;
            obj.padding = ip.Results.Padding;
            obj.endStop = ip.Results.EndStop;
            obj.startPt = ip.Results.StartPt;
            obj.normalizeF = ip.Results.NormalizeF;
            obj.dsampFac = ip.Results.DsampFac;

            
            % Derived parameters
            obj.xpts = getX(size(obj.signals, 2)+1, 25);
            obj.xpts(1) = [];
            obj.roiList = 1:size(obj.signals, 1);
            obj.QI = qualityIndex(mysmooth32(obj.signals, obj.QI_SIGMA));
            obj.badRois = zeros(size(obj.signals,1),1);

            % Adjust for downsampling, if needed
            if ~isempty(obj.dsampFac)
                fprintf('Downsampling...')
                obj.bounds = round(obj.bounds / obj.dsampFac);
                obj.padding = round(obj.padding / obj.dsampFac);
                
                obj.xpts = decimate(obj.xpts, obj.dsampFac);
                dignals = zeros(size(obj.signals,1), numel(obj.xpts), size(obj.signals,3));
                for i = 1:size(obj.signals,1)
                    for j = size(obj.signals,3)
                        dignals(i,:,j) = decimate(mysmooth(obj.signals(i,:,j), obj.smoothFac), obj.dsampFac);
                    end
                end
                obj.signals = dignals;
                fprintf(' Done\n');
            end

            % Analysis window parameters
            if isempty(obj.endStop)
                if isempty(obj.dsampFac)
                    obj.endStop = obj.smoothFac + obj.padding;
                else
                    obj.endStop = round(obj.smoothFac/obj.dsampFac) + obj.padding;
                end
            else % Provided endstop value
                if ~isempty(obj.dsampFac)
                    obj.endStop = round(obj.endStop / obj.dsampFac);
                end
            end

            if isempty(obj.startPt)
                obj.startPt = obj.bounds(1) - obj.padding;
            end

            % Misc parameters
            obj.hasMerged = false;
        end

        function run(obj)
            obj.defaultBadRoiDetect();
            obj.preprocessData();
            obj.detectFeatures();
            obj.clusterFeatures();
        end

        function printParameters(obj)
            fprintf('Removed %u ROIs of %u with QI cut %.3f and motion cut %.4f\n',...
                nnz(obj.badRois), numel(obj.badRois), obj.threshQI, obj.threshMotion);
            fprintf('%u ROIs analyzed\n', nnz(~obj.badRois));
            fprintf('Preprocessing: Smooth factor = %u, bounds = %u %u, frange = %u %u\n',... 
                obj.smoothFac, obj.bounds, obj.fRange(1), obj.fRange(end));
            fprintf('Feature detection: %u features, %u points', obj.nComp, obj.nNonZero);
            if obj.normalizeF
                fprintf(', normalized\n');
            else
                fprintf('\n');
            end
            if obj.hasMerged
                fprintf('Initial clustering: %u clusters\n', obj.clust.K);
                fprintf('Final clustering: %u clusters, merged with R=%.3f\n', ...
                    obj.clust.K, obj.threshR);
            else
                fprintf('Clustering: %u clusters identified\n', obj.clust.K);
            end
        end

        function reportClusters(obj)
            idx = find(obj.clustN == 1);
            if ~isempty(idx)
                for i = 1:numel(idx)
                    fprintf('Cluster %u - Roi %u\n', idx(i), ...
                        obj.roiFinder(obj.clustIdx == idx(i)));
                end
            end
        end

        function value = getRoiRegistry(obj)
            value = table(obj.roiList(~obj.badRois)', obj.clustIdx,...
                'VariableNames', {'Roi', 'Cluster'});
        end

        function roiIDs = getRoisByCluster(obj, clusterID)
            roiIDs = obj.roiFinder(obj.clustIdx == clusterID);
        end

        function traces = getTracesByCluster(obj, clusterID)
            roiIdx = find(obj.clustIdx == clusterID);
            traces = obj.avgData(roiIdx, :);
        end

        function T = getRoiGroups(obj, roiIDs)
            T = [];
            for i = 1:numel(roiIDs)
                if ~obj.badRois(roiIDs(i))
                    T = [T; roiIDs(i), obj.clustIdx(obj.roiFinder == roiIDs(i))]; %#ok<AGROW> 
                end
            end
        end

        function addBadRois(obj, roiIDs)
            obj.badRois(roiIDs) = 1;
        end

        function setBadRois(obj, badRois)
            if islogical(badRois)
                obj.badRois = badRois;
            else
                obj.badRois = zeros(size(obj.signals, 1));
                obj.badRois(badRois) = 1;
            end
        end

        function addBadRoi(obj, roiID)
            obj.badRois(roiID) = 1;
        end

        function data = getPreprocessedData(obj, omittedRois, useFRange)
            if nargin < 2
                omittedRois = ones(size(obj.badRois));
            end
            if nargin < 3
                useFRange = false;
            end
            [~, data] = clusterPreprocess(obj.signals(~omittedRois,:,:),... 
                obj.sigma, obj.startPt);
            if useFRange
                data = data(:, obj.fRange);
            end
        end
    end

    methods
        function defaultBadRoiDetect(obj, plotFlag)
            if nargin < 2
                plotFlag = false;
            end
            if ~isempty(obj.rawSignals)
                obj.getMotionRois(true, plotFlag);
            end
            obj.getLowQI();
            fprintf('Omitting %u of %u ROIs, %u remain\n',...
                nnz(obj.badRois), numel(obj.badRois), nnz(~obj.badRois));
        end

        function roiIDs = getMotionRois(obj, addToBadRois, plotFlag)

            if nargin < 2 || isempty(addToBadRois)
                addToBadRois = true;
            end
            if nargin  < 3
                plotFlag = false;
            end

            roiIDs = roiMotionDetect(obj.rawSignals, ...
                'Cutoff', obj.threshMotion, 'Plot', plotFlag);
            if addToBadRois
                obj.badRois(roiIDs) = 1;
            end
        end

        function roiIDs = getLowQI(obj, addToBadRois, threshQI)
            if nargin < 2 || isempty(addToBadRois)
                addToBadRois = true;
            end
            if nargin == 3
                obj.threshQI = threshQI;
            end
            roiIDs = find(obj.QI < obj.threshQI);
            if addToBadRois
                obj.badRois(roiIDs) = 1;
            end
        end

        function preprocessData(obj)
            [~, obj.avgData] = clusterPreprocess(obj.signals(~obj.badRois,:,:),... 
                obj.sigma, obj.startPt);
        end

        function detectFeatures(obj, plotFlag)
            if nargin < 2
                plotFlag = true;
            end
            % try
                [obj.f, obj.b, obj.v] = computeFeatures(obj.avgData(:, obj.fRange)',...
                    obj.nComp, obj.nNonZero);
            % catch
            %     [obj.f, obj.b, obj.v] = computeFeatures(obj.avgData(:, obj.fRange),...
            %         obj.nComp, obj.nNonZero);
            % end

            if obj.normalizeF
                obj.f = obj.f ./ max(abs(obj.f), [], 2);
            end

            if plotFlag
                obj.plotFeatures();
            end
        end

        function clusterFeatures(obj, plotFlag)
            if nargin < 2
                plotFlag = true;
            end
            obj.clust = performClustering(obj.f');
            obj.clustAvg1 = groupMean(obj.avgData, obj.clust.idx);
            obj.clustN1 = splitapply(@numel, obj.avgData, obj.clust.idx);
            obj.clustN1 = obj.clustN1 / size(obj.avgData, 2);
            fprintf('Found %u clusters\n', obj.clust.K);
            if plotFlag
                obj.plotClusters();
                if nnz(obj.clust.bic < 0) == 0
                    obj.plotBIC();
                end
            end
            obj.reportClusters();
        end

        function mergeClusters(obj, threshR)
            if nargin == 2
                obj.threshR = threshR;
            end

            obj.clustAvg2 = obj.clustAvg;
            obj.clust.idx2 = obj.clust.idx;
            obj.clustN2 = obj.clustN;

            R = triu(corrcoef(obj.clustAvg'), 1);

            while max(R(:)) > obj.threshR 
                [~, ind] = max(R(:));
                [aa, bb] = ind2sub(size(R), ind);
                fprintf('Merging %u and %u - %.3f\n', aa, bb, R(aa, bb));

                obj.clust.idx2(obj.clust.idx2 == bb) = aa;
                tmp = unique(obj.clust.idx2);
                for i = 1:numel(unique(obj.clust.idx2))
                    newIdx = tmp(i);
                    obj.clust.idx2(obj.clust.idx2 == newIdx) = i;
                end

                obj.clust.K2 = numel(unique(obj.clust.idx2));
                obj.clust.idx2 = findgroups(obj.clust.idx2);
                obj.clustAvg2 = groupMean(obj.avgData, obj.clust.idx2);
                obj.clustN2 = splitapply(@numel, obj.avgData, obj.clust.idx2);
                obj.clustN2 = obj.clustN2 / size(obj.avgData, 2);
                R = triu(corrcoef(obj.clustAvg2'), 1);
            end

            fprintf('%u of %u clusters remain\n', obj.numClusters, obj.clust.K);
            fprintf('Max correlation remaining = %.3f\n', max(R(:)));
            obj.hasMerged = true;
            obj.plotClusters();
        end
    end

    methods 
        function mapRoiFeatures(obj)
            figure('Name', 'Feature Matrix'); hold on;
            imagesc(obj.f');
            xlabel('Features');
            ylabel('ROIs');
            colorbar();
            colormap(gray);
        end

        function plotFeatures(obj)
            co = pmkmp(obj.nComp, 'CubicL');
            figure('Name', 'Feature Detection');
            subplot(1, 2, 1); hold on; axis square
            for i = 1:obj.nComp
                plot(obj.xpts(obj.fRange), obj.b(:, i), 'Color', co(i, :));
            end
            title(sprintf('N=%u, F=%u, S=%u', obj.nComp, obj.nNonZero, obj.smoothFac));
            xlabel('Time (s)');
            ylim([-1, 1]);
            stimColor = [0.3 0.3 0.3];
            for i = 1:size(obj.stimWindows, 1)
                addStimPatch(gca, obj.stimWindows(i,:), 'FaceColor', stimColor);
                if stimColor(1) == 0.3
                    stimColor = [0.7 0.7 0.7];
                else
                    stimColor = [0.3 0.3 0.3];
                end
            end
            reverseChildOrder(gca);
            
            subplot(1, 2, 2); hold on; axis square
            superbar(obj.v, 'BarFaceColor', co);
            ylabel('% variance explained');
            title(sprintf('%u features - %.2f% variance', obj.nComp, sum(obj.v)));
            figPos(gcf, 0.9, 0.5);
            drawnow;
        end
        
        function plotClusters(obj)
            co = pmkmp(obj.numClusters, 'CubicL');
            figure('Name', 'Initial Clusters'); 
            subplot(1, 2, 1); hold on;
            set(gca, 'Tag', 'TracesAxis');
            if obj.hasMerged
                str = ', merged';
            else
                str = '';
            end
            title(sprintf('N=%u, F=%u, S=%u%s', obj.nComp, obj.nNonZero, obj.smoothFac, str));
            for i = 1:obj.numClusters
                plot(obj.xpts, obj.clustAvg(i, :),...
                    'Color', co(i, :), 'LineWidth', 1.5,...
                    'DisplayName', sprintf('%u - (%u of %u)', i, obj.clustN(i), sum(obj.clustN)));
            end
            axis tight;
            ylim([-1, 1]);
            stimColor = [0.3 0.3 0.3];
            for i = 1:size(obj.stimWindows, 1)
                addStimPatch(gca, obj.stimWindows(i,:), 'FaceColor', stimColor, 'HideFromLegend', true);
                if stimColor(1) == 0.3
                    stimColor = [0.7 0.7 0.7];
                else
                    stimColor = [0.3 0.3 0.3];
                end
            end
            reverseChildOrder(gca);
            grid on;
            legend('Location', 'southoutside', 'NumColumns', 2);
            subplot(1, 2, 2);
            p = pie(obj.clustN);
            set(findall(p, 'Type', 'Text'), 'FontName', 'Roboto');
            colormap(co);
            subplot(1,2,1);
            drawnow;
        end

        function plotClusters2(obj)
            figure('Name', 'ClusterAverages');
            ax = subplot(1,2,1);
            hold(ax, 'on');
            co = pmkmp(obj.numClusters, 'CubicL');
            offsetFac = 0;
            for i = 1:obj.numClusters
                avgTraces = obj.avgData(obj.clustIdx == i, :);

                shadedErrorBar(obj.xpts, offsetFac + mean(avgTraces, 1),... 
                    std(avgTraces, [], 1),...
                    'lineProps', {'Parent', ax, 'LineWidth', 1.25, 'Color', co(i,:)});
                if i == 1
                    minFac = floor(min(mean(avgTraces,1)));
                end
                offsetFac = offsetFac + max(mean(avgTraces,1)) + 1.25;
            end
            axis(ax, 'tight');
            ylim(ax, [minFac, offsetFac - 1]);
            stimColor = [0.3 0.3 0.3];
            for i = 1:size(obj.stimWindows, 1)
                addStimPatch(ax, obj.stimWindows(i,:), ...
                    'FaceColor', stimColor, 'HideFromLegend', true);
                if stimColor(1) == 0.3
                    stimColor = [0.7 0.7 0.7];
                else
                    stimColor = [0.3 0.3 0.3];
                end
            end
            reverseChildOrder(gca);
            set(gca, 'YTick', [], 'YColor', 'w', 'XTick', []);
            xlabel('Time (s)');

            subplot(1, 2, 2);
            p = pie(obj.clustN);
            set(findall(p, 'Type', 'Text'), 'FontName', 'Roboto');
            colormap(co);
            figPos(gcf, 0.8, 1);
            subplot(1,2,1);
        end 

        function plotBIC(obj)
            figure(); hold on;
            plot(obj.clust.bic, '-ob', 'LineWidth', 1);
            grid on;
            plot(obj.clust.K, obj.clust.bic(obj.clust.K), 'xr');
            ylabel('BIC');
            xlabel('Number of Clusters');
            xlim([0, numel(obj.clust.bic)+1]);
            axis square;
            figPos(gcf, 0.75, 0.5);
        end

        function plotClusterTracesIndiv(obj)
            for i = 1:obj.clust.K
                roiIdx = find(obj.clust.idx == i);
                avgTraces = obj.avgData(roiIdx, :);

                if numel(roiIdx) > 1
                    co = pmkmp(numel(roiIdx), 'CubicL');
                else
                    co = [0.1, 0.1, 0.7];
                end

                figure(); hold on;
                for j = 1:size(avgTraces, 1)
                    y = mysmooth(avgTraces(j, :), 100);
                    plot(obj.xpts, y,...
                        'Color', co(j, :), 'LineWidth', 0.75,...
                        'Display', num2str(roiIdx(j)),...
                        'Tag', num2str(roiIdx(j)));
                    grid on;
                end
                title(['Cluster ', num2str(i)]);
                legend('Location', 'eastoutside');
                figPos(gcf, 0.7, 0.8);
                tightfig(gcf);
                drawnow;
            end
        end

        function plotClusterTraces(obj)
            nPlots = 4;
            for ind = 0:(ceil(obj.numClusters)/4-1)
                figure();
                for i = (ind*nPlots+1):(ind*nPlots+nPlots)
                    if i > obj.numClusters
                        continue
                    end
                    iPlot = i - (ind*nPlots);
                    roiIdx = find(obj.clustIdx == i);
                    avgTraces = obj.avgData(roiIdx, :);

                    if numel(roiIdx) > 1
                        co = pmkmp(numel(roiIdx), 'CubicL');
                    else
                        co = [0.1, 0.1, 0.7];
                    end
                    subplot(1, nPlots, iPlot); hold on;
                    for j = 1:size(avgTraces, 1)
                        y = mysmooth(avgTraces(j, :), 100);
                        plot(obj.xpts, y,...
                            'Color', co(j, :), 'LineWidth', 0.75,...
                            'Display', num2str(roiIdx(j)),...
                            'Tag', num2str(roiIdx(j)));
                    end
                    grid on;
                    title(['Cluster ', num2str(i)]);
                    set(gca, 'YTickLabel', []);
                end
                figPos(gcf, 1.5, 0.5);
                tightfig(gcf);
            end
        end
       
    end

    methods

        function value = get.numFeatures(obj)
            value = size(obj.f, 1);
        end

        function value = get.numClusters(obj)
            if isfield(obj.clust, 'K2') && ~isempty(obj.clust.K2)
                value = obj.clust.K2;
            elseif ~isempty(obj.clust)
                value = obj.clust.K;
            else
                value = [];
            end
        end

        function value = get.clustAvg(obj)
            if ~isempty(obj.clustAvg2)
                value = obj.clustAvg2;
            else
                value = obj.clustAvg1;
            end
        end

        function value = get.clustN(obj)
            if ~isempty(obj.clustN2)
                value = obj.clustN2;
            else
                value = obj.clustN1;
            end
        end

        function value = get.roiFinder(obj)
            value = obj.roiList(~obj.badRois);
        end

        function value = get.clustIdx(obj)
            if isfield(obj.clust, 'idx2') && ~isempty(obj.clust.idx2)
                value = obj.clust.idx2;
            else
                value = obj.clust.idx;
            end
        end

        function value = get.badRoiIDs(obj)
            value = find(obj.badRois);
        end

        function value = get.fRange(obj)
            endPt = size(obj.signals, 2) - obj.endStop;
            value = obj.startPt:endPt;
        end

        function value = get.sigma(obj)
            if ~isempty(obj.dsampFac)
                value = 1;
            else
                value = obj.smoothFac;
            end
        end
    end
end 