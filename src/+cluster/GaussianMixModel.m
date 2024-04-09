classdef GaussianMixModel < handle

    properties
        Data
        Mean
        Sigma
        SD
        Model
    end

    properties
        xLabel
        yLabel
    end

    properties
        xyData
        models
        numComponents
        xyBounds
        covarianceType
        sharedCovariance
        regularizationValue
        evalMetric
        numReplicates
    end

    properties (Dependent)
        PDF
    end

    methods
        function obj = GaussianMixModel(xyData, numComponents, opts)
            arguments
                xyData                  (:,2)       double
                numComponents           (1,1)       {mustBeInteger}
                opts.CovarianceType     string                      = 'diagonal'
                opts.SharedCovariance   (1,1)       logical         = false
                opts.Regularization     (1,1)       double          = 1e-5
                opts.NumReplicates      (1,1)       {mustBeInteger} = 10
                opts.EvalMetric         string {mustBeMember(opts.EvalMetric, ["AIC", "BIC",  "NLL"])}= "AIC"
                opts.xLabel             string                      = "X"
                opts.yLabel             string                      = "Y"
            end

            obj.xyData = xyData;
            obj.numComponents = numComponents;
            obj.numReplicates = opts.NumReplicates;
            obj.evalMetric = opts.EvalMetric;
            obj.sharedCovariance = opts.SharedCovariance;
            obj.covarianceType = opts.CovarianceType;
            obj.regularizationValue = opts.Regularization;

            obj.determineBounds();
            obj.runFit();
        end
    end

    % Dependent set/get methods
    methods

        function out = get.Sigma(obj)
            out = obj.Model.Sigma;
        end

        function out = get.Mean(obj)
            out = obj.Model.mu;
        end

        function out = get.SD(obj)
            out = sqrt(obj.Sigma);
        end

        function out = get.PDF(obj)
            out = @(x,y) arrayfun(@(x0, y0) pdf(obj.Model, [x0 y0]), x, y);
        end
    end

    methods
        function setComponents(obj, numComponents)
            if obj.numComponents == numComponents
                return
            end
            obj.numComponents = numComponents;
            obj.runFit();
        end

        function determineBounds(obj)

            yBounds = 1.05 * [min(obj.xyData(:,2)), max(obj.xyData(:,2))];
            xBounds = 1.05 * [min(obj.xyData(:,1)), max(obj.xyData(:,1))];
            obj.xyBounds = [xBounds, yBounds];
        end
    end

    % PLotting and post-hoc analysis methods
    methods
        function cObj = contourPlot(obj, opts)
            arguments
                obj                     GaussianMixModel
                opts.Fill       (1,1)   logical = false
            end

            fh = figure(); hold on;
            axis(opts.Bounds);
            fc = fcontour(obj.PDF, 'MeshDensity', 100);
            % Have to do some weird plot switching to get the plotting
            % properties offered by contour but not fcontour...
            X = fc.XData;
            Y = fc.YData;
            Z = fc.ZData/max(fc.ZData(:));

            figure(); hold on;
            axis(opts.Bounds);
            if opts.Fill
                [~, cObj] = contourf(X, Y, Z);
            else
                [~, cObj] = contour(X, Y, Z, 'LineWidth', 1);
            end
            colormap(pmkmp(10, 'CubicL'));
            set(gca, 'CLim', [0 1]);
            cb = colorbar();
            cb.Label.String = "Propability Distribution";
            axis(opts.Bounds);

            delete(fh);
        end

        function [clusterX, mahalDist, outliers, ax] = cluster(obj, opts)
            arguments
                obj
                opts.Threshold       (1,1)  {mustBeInRange(opts.Threshold, 0.1, 0.999)}  = 0.95
                opts.PlotOutliers    (1,1)  logical        = false
            end

            cutoff = sqrt(chi2inv(opts.Threshold, 2));
            fprintf('Cutoff is %.2f SDs\n', cutoff);

            [X, Y] = meshgrid(obj.xyBounds(1):0.05:obj.xyBounds(2), ...
                obj.xyBounds(3):0.1:obj.xyBounds(4));
            XY = [X(:) Y(:)];
            clustMap = zeros(size(X, 1), size(Y, 2));

            clusterX = cluster(obj.Model, obj.xyData);
            mahalDist = mahal(obj.Model, XY);

            ax = axes('Parent', figure());
            hold(ax, 'on');
            colororder('sail');
            h1 = gscatter(obj.xyData(:,1), obj.xyData(:,2), clusterX);
            for i = 1:obj.numComponents
                idx = mahalDist(:,i) <= cutoff;
                clustMap(idx) = i;
                iColor = h1(i).Color*0.75 - 0.5*(h1(i).Color - 1);
                h2 = plot(ax, XY(idx, 1), XY(idx, 2), '.', ...
                    'Color', iColor, 'MarkerSize', 2,...
                    'Tag', sprintf('Area%i', i));
                uistack(h2, 'bottom'); noLegend(h2);
            end
            h3 = plot(ax, obj.Model.mu(:,1), obj.Model.mu(:,2), 'xk',...
                'LineWidth', 2, 'MarkerSize', 10, 'Tag', 'Means');
            noLegend(h3);
            ylabel(obj.yLabel); xlabel(obj.xLabel);

            outliers = obj.getOutliers(cutoff);
            if opts.PlotOutliers
                plot(ax, obj.xyData(outliers,1), obj.xyData(outliers,2),...
                    '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 12, ...
                    'Tag', 'Outliers');
            end
            fprintf('%u of %u synapses were outliers\n', ...
                nnz(outliers), numel(outliers));
        end

        function outliers = getOutliers(obj, cutoff)
            arguments
                obj
                cutoff      (1,1)       {mustBeNonnegative} = 0.95
            end
            distMatrix = mahal(obj.Model, obj.xyData);
            outliers = min(distMatrix, [], 2) > cutoff;
        end

        function [clustMap, centroids, semiAxes, rotAngles] = clusterInfo(obj, opts)
            arguments
                obj
                opts.IncrementY         = 0.1
                opts.Threshold          = 0.95
            end

            cutoff = sqrt(chi2inv(opts.Threshold, 2));

            [X, Y] = meshgrid(-1:0.01:1, obj.xyBounds(3):opts.IncrementY:obj.xyBounds(4));
            XY = [X(:) Y(:)];
            clustMap = zeros(size(X, 1), size(Y, 2));

            mahalDist = mahal(obj.Model, XY);
            for i = 1:obj.numComponents
                idx = mahalDist(:,i) <= cutoff;
                clustMap(idx) = i;
            end

            stats = struct2table(regionprops(clustMap, ...
                'MajorAxisLength', 'MinorAxisLength', 'Orientation'));

            centroids = obj.Mean;
            semiAxes = 0.5 * [stats.MajorAxisLength, stats.MinorAxisLength];
            rotAngles = stats.Orientation;

            figure(); hold on;
            iObj = imagesc(clustMap);
            set(iObj, 'XData', X(1,:), 'YData', Y(:,1));
            scatter(obj.xyData(:,1), obj.xyData(:, 2), '.w');
            axis equal tight;
        end

        function [aics, bics] = checkAIC(obj, componentRange)
            arguments
                obj
                componentRange      = 2:10
            end

            aics = zeros(size(componentRange));
            bics = zeros(size(componentRange));
            fitOptions = statset("MaxIter", 1000, "Display", "final");
            for i = 1:numel(componentRange)
                iModel = fitgmdist(obj.xyData, componentRange(i),...
                    "CovarianceType", obj.covarianceType,...
                    "SharedCovariance", obj.sharedCovariance,...
                    "Replicates", obj.numReplicates,...
                    "RegularizationValue", obj.regularizationValue,...
                    "Options", fitOptions);
                aics(i) = iModel.AIC;
                bics(i) = iModel.BIC;
            end

            figure();
            subplot(1,2,1); hold on; grid on;
            plot(componentRange, aics, '-ob');
            xlim([componentRange(1), componentRange(end)]);
            title('AIC'); xlabel('Number of Compoonents');

            subplot(1,2,2); hold on; grid on;
            plot(componentRange, bics, '-ob');
            xlim([componentRange(1), componentRange(end)]);
            title('BIC'); xlabel('Number of Compoonents');
            figPos(gcf, 1, 0.75);
        end

        function [idx, P] = posteriorProbability(obj)
            P = posterior(obj.Model, obj.xyData);
            idx = cluster(obj.Model, obj.xyData);

            fh = figure();
            for i = 1:obj.numComponents
                subplot(1,obj.numComponents, i); hold on;
                scatter(obj.xyData(idx == i,1), obj.xyData(idx == i, 2),...
                    10, P(idx == i, i), 'o');
                scatter(obj.xyData(idx ~= i,1), obj.xyData(idx ~= i, 2),...
                    10, P(idx ~= i, i), 'x');
                cmap = jet(80);
                colormap(cmap(9:72,:));
                colorbar();
                title(sprintf('Comp %u PP', i));
                axis square tight
            end
            figPos(fh, 1.75, 0.8);
            tightfig(fh);
        end

        function checkComponents(obj, opts)
            arguments
                obj
                opts.CompRange          = 2:10
                opts.NumRepeats         = 1
                opts.Criterion      {mustBeMember(opts.Criterion, ["gap", "silhouette", "CalinskiHarabasz", "DaviesBouldin"])} = "CalinskiHarabasz"
            end

            criterionValues = zeros(opts.NumRepeats, numel(opts.CompRange));
            % Why can't we run repeats using evalclusters?
            for i = 1:opts.NumRepeats
                iEval = evalclusters(obj.xyData, 'gmdistribution', ...
                    opts.Criterion, 'KList', opts.CompRange);
                criterionValues(i,:) = iEval.CriterionValues;
            end

            figure(); hold on;
            if opts.NumRepeats == 1
                plot(iEval);
            else
                errorbar(opts.CompRange, mean(criterionValues, 1), ...
                    std(criterionValues, [], 1), 'b');
                grid on;
            end
            title(opts.Criterion);

            figPos(gcf, 0.5, 0.5);
        end

        function passTable = checkCutoff(obj, cutoffRange)
            arguments
                obj
                cutoffRange = [0.9:0.01:1];
            end

            numPassed = zeros(size(cutoffRange));
            stDevs = zeros(size(cutoffRange));
            for i = 1:numel(cutoffRange)
                stDevs(i) = sqrt(chi2inv(cutoffRange(i), 2));
                mDist = mahal(obj.Model, obj.xyData);
                numPassed(i) = nnz(sum(mDist <= stDevs(i), 2));
            end

            figure(); hold on;
            plot(cutoffRange, numPassed, '-ob');

            passTable = table(cutoffRange', stDevs', numPassed',...
                'VariableNames', {'Cutoff', 'SD', 'NumPassed'});
        end

        function [regions, mask, stats] = getIndividualRegions(obj, threshold, opts)
            arguments
                obj
                threshold               = 0.2
                opts.Bounds1D           =  obj.xyBounds(3:4)
                opts.Increment1D        = diff(obj.xyBounds(3:4))/200
            end

            x1 = opts.Bounds1D(1):opts.Increment1D:opts.Bounds1D(2);
            [X, Y] = meshgrid(x1, x1);
            XY = [X(:) Y(:)];

            regions = zeros(numel(x1), numel(x1), obj.numComponents);
            areas = zeros(1, obj.numComponents);
            for i = 1:obj.numComponents
                y = mvnpdf(XY, obj.Mean(i,:), sqrt(obj.Sigma(:,:,i)));
                y = reshape(y, length(x1), length(x1));
                areas(i) = sum(y(:) * obj.Model.ComponentProportion(i)) * (opts.Bounds1D(2) - opts.Bounds1D(1)) * (opts.Bounds1D(2) - opts.Bounds1D(1)) / numel(X);
                regions(:,:,i) = round(y, 1);
            end
            disp(areas)

            mask = zeros(numel(x1), numel(x1));
            for i = 1:obj.numComponents
                mask = mask + (i*double(squeeze(regions(:,:,i)) >= threshold));
            end

            stats = regionprops(mask,...
                'Area', 'FilledArea', 'Centroid', 'EquivDiameter', ...
                'MajorAxisLength', 'MinorAxisLength');
            stats = struct2table(stats);
        end
    end

    methods (Access = private)
        function runFit(obj)
            fitOptions = statset("Display", "final");
            obj.Model = fitgmdist(obj.xyData, obj.numComponents,...
                "CovarianceType", obj.covarianceType,...
                "SharedCovariance", obj.sharedCovariance,...
                "RegularizationValue", obj.regularizationValue,...
                "Replicates", obj.numReplicates,...
                "Options", fitOptions);

            fprintf('Best model: BIC = %.2f, AIC = %.2f, NLL = %.2f\n',...
                obj.Model.BIC, obj.Model.AIC, obj.Model.NegativeLogLikelihood);
        end
    end

    methods (Static, Access = private)
        function outData = checkData(inData)
            % Look for outliers - synapses that are greater than 25 microns
            % away from the nearest neighboring synapse can't possibly be
            % part of a hotspot but will skew the fit.

            nearestNeighbor = zeros(1, size(inData, 1));
            for i = 1:size(inData,1)
                neighborDist = fastEuclid2d(inData(:,1:2), inData(i,1:2));
                neighborDist(i) = Inf; % ignore self
                nearestNeighbor(i) = min(neighborDist);
            end
            assignin('base', 'nearestNeighbor', nearestNeighbor)
            idx = nearestNeighbor > 25;
            fprintf('Removing %u outliers\n', nnz(idx));
            outData = inData(~idx, :);

            % 25 microns was chosen because visual inspection of the spatial
            % density map indicates that even a synapse in the center of a
            % coolspot should be within 25 microns of a nearest neighbor
            % while a true outlier will be >25 microns away.
        end
    end
end