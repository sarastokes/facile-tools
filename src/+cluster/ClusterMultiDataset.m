classdef ClusterMultiDataset < handle 

    properties
        DSET
        %signals 
        xpts 
        UUIDs
        dsetIDs
        avgData
        avgData2
        padVal 
        stimWindows
        startPt
        endStop

        nNonZero = 50;
        nComp = 20;

        f 
        b
        v
        clust
        clustN
        clustAvg
        corrCutoff
    end

    properties (Dependent)
        numDatasets
    end

    methods 
        function obj = ClusterMultiDataset(DSET, nComp, nPts, varargin)
            obj.DSET = DSET;
            obj.nComp = nComp;
            obj.nNonZero = nPts;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'StimWindows', [], @isnumeric);
            addParameter(ip, 'EndStop', 100, @isnumeric);
            addParameter(ip, 'StartPt', 505, @isnumeric);
            addParameter(ip, 'PadVal', 100, @isnumeric);
            addParameter(ip, 'MotionCutoff', 0.008, @isnumeric);
            addParameter(ip, 'X', [], @isnumeric);
            parse(ip, varargin{:});

            obj.endStop = ip.Results.EndStop;
            obj.startPt = ip.Results.StartPt;
            obj.stimWindows = ip.Results.StimWindows;
            obj.padVal = ip.Results.PadVal;
            obj.xpts = ip.Results.X;
        end

        function value = get.numDatasets(obj)
            value = numel(obj.DSET);
        end

        function preprocessData(obj)
            uuids = string.empty();
            signals = [];
            dsets = [];
            for k = 1:obj.numDatasets
                for i = 1:obj.DSET(k).numUUIDs
                    if obj.DSET(k).uidTable.Bad(i)
                        continue
                    end
                    
                    data = obj.DSET(k).getUuidResponse(obj.DSET(k).uidTable.UUID(i), false);
    
                    % Keep the good data
                    idx = obj.DSET(k).isValid(i, []);
                    if nnz(idx) == 0
                        continue
                    end
                    data = data(idx, :);
    
                    % Normalize the good data
                    if ~isempty(obj.startPt)
                        data = data';
                        data = bsxfun(@minus, data,...
                            median(data(obj.padVal+1 : obj.startPt, :), 1));
                        data = data';
                    end
    
                    if ~isempty(idx) && numel(idx) > 2
                        data = mean(data, 1) / max(abs(mean(data, 2, 'omitnan')));
                        signals = cat(1, signals, data);
                        uuids = cat(1, uuids, obj.DSET(k).uidTable.UUID(i));
                        dsets = cat(1, dsets, k);
                    end
                end
            end
            obj.avgData = signals;
            obj.UUIDs = uuids;
            obj.dsetIDs = dsets;
            if isempty(obj.xpts)
                obj.xpts = getX2(size(obj.avgData, 2), 25);
            end

            obj.avgData2 = bsxfun(@rdivide, ...
                bsxfun(@minus, obj.avgData, mean(obj.avgData, 2)),... 
                std(obj.avgData, [], 2));

            fprintf('Final dataset contains %u ROIs\n', size(obj.avgData,1));
        end

        function detectFeatures(obj)
            [obj.f, obj.b, obj.v] = computeFeatures(...
                obj.avgData(:, obj.startPt:end-obj.padVal)',... 
                obj.nComp, obj.nNonZero);
            obj.plotFeatureDetection();
        end

        function clusterFeatures(obj, varargin)
            obj.clust = performClustering(obj.f', varargin{:});
            obj.clustAvg = groupMean(obj.avgData, obj.clust.idx);
            obj.clustN = splitapply(@numel,obj.avgData, obj.clust.idx);
            obj.clustN = obj.clustN / size(obj.avgData, 2);
            fprintf('Found %u clusters\n', obj.clust.K);
            obj.plotClusters();
        end

        function mergeFeatures(obj, threshR)
            obj.corrCutoff = threshR;
            
            while max(R(:)) > obj.corrCutoff 
                [~, ind] = max(R(:));
                [aa, bb] = ind2sub(size(R), ind);
                fprintf('Merging %u and %u - %.3f\n', aa, bb, R(aa, bb));

                obj.clust.idx(obj.clust.idx == bb) = aa;
                tmp = unique(obj.clust.idx);
                for i = 1:numel(unique(obj.clust.idx))
                    newIdx = tmp(i);
                    obj.clust.idx(obj.clust.idx == newIdx) = i;
                end

                obj.clust.K = numel(unique(obj.clust.idx));
                obj.clust.idx = findgroups(obj.clust.idx);
                obj.clustAvg = groupMean(obj.avgData, obj.clust.idx);
                obj.clustN = splitapply(@numel, obj.avgData, obj.clust.idx);
                obj.clustN = obj.clustN / size(obj.avgData, 2);
                R = triu(corrcoef(obj.clustAvg'), 1);
            end

            fprintf('%u of %u clusters remain\n', obj.numClusters, obj.clust.K);
            fprintf('Max correlation remaining = %.3f\n', max(R(:)));
        end
    end

    methods
        function plotFeatureDetection(obj)
            co = pmkmp(obj.nComp, 'CubicL');

            figure('Name', 'Feature Detection');
            subplot(1, 2, 1); hold on; axis square
            for i = 1:obj.nComp
                plot(obj.xpts(obj.startPt:end-obj.padVal), obj.b(:, i),... 
                    'Color', co(i, :));
            end
            title(sprintf('F=%u, N=%u, R=%u',... 
                obj.nComp, obj.nNonZero, numel(obj.UUIDs)));
            xlabel('Time (s)');

            subplot(1, 2, 2); hold on; axis square
            superbar(obj.v, 'BarFaceColor', co);
            ylabel('percent variance explained');
            title(sprintf('%u features - %.2f% variance',... 
                obj.nComp, sum(obj.v)));
            figPos(gcf, 0.9, 0.5);
            drawnow;
        end

        function plotClusters(obj)
            co = pmkmp(obj.clust.K, 'CubicL');
            figure('Name', 'Initial Clusters'); 
            subplot(1, 2, 1); hold on;
            set(gca, 'Tag', 'TracesAxis');
            
            title(sprintf('F=%u, N=%u, R=%u',... 
                obj.nComp, obj.nNonZero, numel(obj.UUIDs)));

            for i = 1:obj.clust.K
                plot(obj.xpts, obj.clustAvg(i, :),...
                    'Color', co(i, :), 'LineWidth', 1.5,...
                    'DisplayName', sprintf('%u - (%u of %u)', i, obj.clustN(i), sum(obj.clustN)));
            end
            axis tight;
            xlabel('Time (s)');
            roundYAxisLimits(gca, 0.5);
            if ~isempty(obj.DSET(1).ups)
                addStimPatch(gca, obj.DSET.ups,... 
                    'HideFromLegend', true, obj.DSET.INC_PROPS{:});
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
    end
end 