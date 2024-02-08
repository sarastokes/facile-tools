classdef ClusterStimuli < handle 

    properties 
        datasets  
        avgData
        badRois
        roiList
        xRanges
        f 

        clustN1
        clustN2
        clustAvg1
        clustAvg2
        clust

        maxClust
        threshR
        normalizeF

        hasMerged
    end

    properties (Dependent)
        numClusters
        clustAvg
        clustN
        clustIdx
        roiFinder
    end


    properties (Hidden, Constant)
        FRAME_RATE = 25;
    end

    methods
        function obj = ClusterStimuli(varargin)
            obj.threshR = 0.9;
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'MaxClust', 25, @isnumeric);
            addParameter(ip, 'NormalizeF', true, @islogical);
            parse(ip, varargin{:});

            obj.maxClust = ip.Results.MaxClust;
            obj.normalizeF = ip.Results.NormalizeF;
        end

        function value = getRoiRegistry(obj)
            value = [obj.roiFinder', obj.clustIdx];
        end

        function x = getX(obj, dsetID)
            xRange = obj.xRanges(dsetID, :);
            if dsetID ~= 1
                xRange = xRange - obj.xRanges(dsetID-1,2);
            end
            x = xRange(1):xRange(2);
            x = x / obj.FRAME_RATE;
        end

        function [y, x] = getTraces(obj, dsetID, clusterID)
            y = obj.avgData(obj.clustIdx == clusterID, rangeCol(obj.xRanges(dsetID,:)));
            if nargout == 2
                %x = obj.getX(dsetID);
                x = obj.datasets(dsetID).xpts;
            end
        end

        function T = getRoiGroups(obj, roiIDs)
            T = [];
            for i = 1:numel(roiIDs)
                if ~obj.badRois(roiIDs(i))
                    T = [T; roiIDs(i), obj.clustIdx(obj.roiFinder == roiIDs(i))];
                end
            end
        end

        function add(obj, dset)
            obj.datasets = cat(1, obj.datasets, dset);
            if numel(obj.datasets) == 1
                obj.badRois = obj.datasets(1).badRois;
                obj.roiList = dset.roiList;
            else
                roiIDs = intersect(find(obj.badRois), find(dset.badRois));
                obj.badRois = zeros(size(obj.badRois));
                obj.badRois(roiIDs) = 1;
            end

            obj.update();
        end

        function setBadRoi(obj, roiID)
            obj.badRois(roiID) = 1;
        end

        function clusterFeatures(obj, plotFlag)
            if nargin < 2
                plotFlag = true;
            end
            if obj.normalizeF 
                fMatrix = obj.f ./ max(abs(obj.f), [], 2);
            else
                fMatrix = obj.f;
            end
            obj.clust = performClustering(fMatrix', 'MaxClust', obj.maxClust);
            obj.clustAvg1 = groupMean(obj.avgData, obj.clust.idx);
            obj.clustN1 = splitapply(@numel, obj.avgData, obj.clust.idx);
            obj.clustN1 = obj.clustN1 / size(obj.avgData, 2);
            fprintf('Found %u clusters\n', obj.clust.K);
            if plotFlag
                obj.plotClusters3();
                obj.plotBIC();
            end
            obj.hasMerged = false;
        end

        function clusterFeaturesOnlyGood(obj, plotFlag)
            warning('off', 'stats:gmdistribution:posterior:MissingData');
            if nargin < 2
                plotFlag = true;
            end
            iF = obj.f;
            for i = 1:numel(obj.datasets)
                remainingBadRois = obj.datasets(i).badRois(~obj.badRois);
                iF(1:obj.datasets(i).numFeatures, find(remainingBadRois)) = NaN;
            end
            obj.clust = performClustering(iF');
            obj.clustAvg1 = groupMean(obj.avgData, obj.clust.idx);
            obj.clustN1 = splitapply(@numel, obj.avgData, obj.clust.idx);
            obj.clustN1 = obj.clustN1 / size(obj.avgData, 2);
            fprintf('Found %u clusters\n', obj.clust.K);
            if plotFlag
                obj.plotClusters();
            end
            warning('on', 'stats:gmdistribution:posterior:MissingData');
        end

        function plotClusters(obj)
            co = pmkmp(obj.numClusters, 'CubicL');
            figure('Name', 'Initial Clusters'); 
            for i = 1:numel(obj.datasets)
                subplot(1, numel(obj.datasets)+1, i); hold on;
                if obj.hasMerged
                    str = ', merged';
                else
                    str = '';
                end
                title(sprintf('N=%u, F=%u, S=%u%s', obj.datasets(i).nComp,...
                    obj.datasets(i).nNonZero, obj.datasets(i).smoothFac, str));
                for j = 1:obj.numClusters
                    plot(obj.getX(i), obj.clustAvg(j, rangeCol(obj.xRanges(i,:))),...
                        'Color', co(j, :), 'LineWidth', 1.5,...
                        'DisplayName', sprintf('%u - (%u of %u)', j, obj.clustN(j), sum(obj.clustN)));
                end
                axis tight;
                ylim([-1, 1]);
                stimColor = [0.3 0.3 0.3];
                for j = 1:size(obj.datasets(i).stimWindows, 1)
                    addStimPatch(gca, obj.datasets(i).stimWindows(j,:), 'FaceColor', stimColor, 'HideFromLegend', true);
                    if stimColor(1) == 0.3
                        stimColor = [0.7 0.7 0.7];
                    else
                        stimColor = [0.3 0.3 0.3];
                    end
                end
                reverseChildOrder(gca);
                grid on;
                legend('Location', 'southoutside', 'NumColumns', 2);
            end
            subplot(1, numel(obj.datasets)+1, numel(obj.datasets)+1);
            pie(obj.clustN);
            colormap(co);
        end

        function plotBIC(obj)
            figure(); hold on;
            plot(obj.clust.bic, '-ob', 'LineWidth', 1);
            grid on;
            plot(obj.clust.K, obj.clust.bic(obj.clust.K), 'xr');
            ylabel('BIC');
            xlabel('Number of Clusters');
            if nnz(obj.clust.bic < 0) == 0
                set(gca, 'YScale', 'log');
            end
            axis square
            figPos(gcf, 0.5, 0.5);
        end

        function plotClusters2(obj)
            co = pmkmp(obj.numClusters, 'CubicL');
            figure(); 
            for i = 1:numel(obj.datasets)
                for j = 1:obj.numClusters
                    ii = (j-1)*numel(obj.datasets) + i; 

                    ax = subplot(obj.numClusters+2, numel(obj.datasets), ii); hold on;
                    title(sprintf('Cluster %u (%u)', j, obj.clustN(j)));
                    plot(ax, obj.getX(i), obj.clustAvg(j, rangeCol(obj.xRanges(i,:))),...
                        'Color', co(j, :), 'LineWidth', 1.5,...
                        'DisplayName', sprintf('%u - (%u of %u)', j, obj.clustN(j), sum(obj.clustN)));
                    axis(ax, 'tight'); grid(ax, 'on');
                    ylim(ax, [-1 1]);
                    set(ax, 'XTickLabel', []);
                    stimColor = [0.3 0.3 0.3];
                    for k = 1:size(obj.datasets(i).stimWindows, 1)
                        addStimPatch(ax, obj.datasets(i).stimWindows(k,:), 'FaceColor', stimColor, 'HideFromLegend', true);
                        if stimColor(1) == 0.3
                            stimColor = [0.7 0.7 0.7];
                        else
                            stimColor = [0.3 0.3 0.3];
                        end
                    end
                    reverseChildOrder(ax);
                end
            end
            subplot(obj.numClusters+2, 1, obj.numClusters+1:obj.numClusters+2);
            p = pie(obj.clustN);
            set(findall(p, 'Type', 'Text'), 'FontName', 'Roboto');
            colormap(co);

            figPos(gcf, 0.75, 1.75);
            tightfig(gcf);
        end

        function plotClusters3(obj)
            co = pmkmp(obj.numClusters, 'CubicL');
            figure(); 
            for i = 1:numel(obj.datasets)
                for j = 1:obj.numClusters
                    ii = (j-1)*numel(obj.datasets) + i; 

                    ax = subplot(obj.numClusters+2, numel(obj.datasets), ii); hold on;
                    title(sprintf('Cluster %u (%u)', j, obj.clustN(j)));
                    [avgTraces, x] = obj.getTraces(i, j);
                    shadedErrorBar(x, mean(avgTraces, 1), std(avgTraces, [], 1),...
                        'lineProps', {'Parent', ax, 'LineWidth', 1.25, 'Color', co(j,:)});
                    axis(ax, 'tight'); grid(ax, 'on');
                    ylim(ax, [-1 1]);
                    set(ax, 'XTickLabel', [], 'YTickLabel', []);
                    stimColor = [0.3 0.3 0.3];
                    for k = 1:size(obj.datasets(i).stimWindows, 1)
                        addStimPatch(ax, obj.datasets(i).stimWindows(k,:), ...
                            'FaceColor', stimColor, 'HideFromLegend', true);
                        if stimColor(1) == 0.3
                            stimColor = [0.7 0.7 0.7];
                        else
                            stimColor = [0.3 0.3 0.3];
                        end
                    end
                    reverseChildOrder(ax);
                end
            end
            subplot(obj.numClusters+2, 1, obj.numClusters+1:obj.numClusters+2);
            p = pie(obj.clustN);
            set(findall(p, 'Type', 'Text'), 'FontName', 'Roboto');
            colormap(co);

            figPos(gcf, 0.75, 1.75);
            tightfig(gcf);
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
            obj.plotClusters3();
        end
    end

    methods (Access = private)
        function update(obj)
            obj.avgData = [];
            obj.f = [];
            obj.xRanges = [];
            for i = 1:numel(obj.datasets)
                iData = obj.datasets(i).getPreprocessedData(obj.badRois, true);
                iFeatures = zeros(size(obj.datasets(i).b, 2), size(iData,1));
                for j = 1:size(iData, 1) % Rois
                    for k = 1:size(obj.datasets(i).b, 2)  % Features
                        iFeatures(k, j) = iData(j, :) * obj.datasets(i).b(:, k);
                    end
                end
                fullData = obj.datasets(i).getPreprocessedData(obj.badRois, false);
                obj.avgData = cat(2, obj.avgData, fullData);
                obj.f = cat(1, obj.f, iFeatures);  % features * rois
                if i == 1
                    obj.xRanges = [1 size(fullData, 2)];
                else
                    obj.xRanges = cat(1, obj.xRanges, [1 size(fullData, 2)] + obj.xRanges(i-1, 2));
                end
            end
        end
    end

    methods
        
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

    end
end 