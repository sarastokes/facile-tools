classdef ClusterOptimization < handle

    properties (SetAccess = private)
        dataset         (1,1)       % ao.core.Dataset
        stimName        (1,1)       string
        bkgd            (1,2)       double  = [250 498]
        dfProps                     cell    = {'Smooth', 100}
        sampleRate      (1,1)       double  = 25
        roiIDs          (1,:)       double      {mustBeInteger}
    end

    properties
        analysisRange   (1,2)       double  = [501 125]
        downsample      (1,1)       {mustBeInteger, mustBeNonnegative} = 0
        ups                         double
        downs                       double
    end

    properties
        % Original data
        data0                       double
        xpts0           (1,:)       double      = NaN
        QI0             (:,1)       double      = NaN
        % Clipped data
        dataClipped                 double
        xptsClipped     (1,:)       double      = NaN
        QIClipped       (:,1)       double      = NaN
        % Downsampled data
        dataDownsampled             double
        xptsDownsampled (1,:)       double      = NaN
        QIDownsampled   (:,1)       double      = NaN
        % Normalized and averaged data
        dataFinal                   double
    end

    properties (Hidden, Dependent)
        stimType        (1,1)       string
    end

    % Clustering parameters
    properties
        numPCs          (1,1)       {mustBeInteger} = 3
        nComp           (1,1)       {mustBeInteger, mustBePositive} = 10
        nPoints         (1,1)       {mustBeInteger, mustBePositive} = 10
        useSVD          (1,1)       logical = false
        useSPCA         (1,1)       logical = true
        maxCorr         (1,1)       {mustBeInRange(maxCorr, 0, 1)} = 1
    end

    properties (Hidden, Dependent)
        dualFeatures    (1,1)       logical
    end

    methods
        function obj = ClusterOptimization(dataset, stimName, opts)
            arguments
                dataset
                stimName                (1,1)       string
                opts.bkgd               = []
                opts.dfProps            = {}
                opts.analysisRange      = []
                opts.sampleRate         = []
            end

            obj.dataset = dataset;
            obj.roiIDs = 1:obj.dataset.numROIs;

            obj.stimName = stimName;
            if ~ismember(stimName, obj.dataset.stim.Stimulus)
                error('ClusterOptimization:InvalidStimulus',...
                    'Stimulus %s not found in dataset', stimName);
            end

            if ~isempty(opts.bkgd)
                obj.bkgd = opts.bkgd;
            end
            if ~isempty(opts.dfProps)
                obj.dfProps = opts.dfProps;
            end
            if ~isempty(opts.analysisRange)
                obj.analysisRange = opts.analysisRange;
            end
            if ~isempty(opts.sampleRate)
                obj.sampleRate = opts.sampleRate;
            end
        end
    end

    % Dependent set/get methods
    methods
        function value = get.dualFeatures(obj)
            value = obj.useSVD & obj.useSPCA;
        end

        function value = get.stimType(obj)
            if isa(obj.dataset, 'ao.core.DatasetLED2')
                value = "SPECTRAL";
            else
                value = "SPATIAL";
            end
        end
    end

    methods
        function loadData(obj)
            [obj.data0, obj.xpts0] = obj.dataset.getStimulusData(obj.stimName,...
                obj.bkgd, obj.dfProps{:});
            if ~ismatrix(obj.data0)
                obj.QI0 = qualityIndex(obj.data0);
            end
        end

        function postProcess(obj, opts)
            arguments
                obj
                opts.Downsample         = []
                opts.analysisRange      = []
            end

            if ~isempty(opts.Downsample)
                obj.downsample = opts.Downsample;
            end
            if ~isempty(opts.analysisRange)
                obj.analysisRange = opts.analysisRange;
            end


            % Clip data
            [obj.dataClipped, obj.xptsClipped] = downsampleMean(obj.data0,...
                obj.analysisRange, 2, obj.xpts0);
            obj.QIClipped = qualityIndex(obj.dataClipped);

            % Downsample data
            obj.dataDownsampled = downsampleMean(obj.dataClipped, obj.downsample);
            obj.xptsDownsampled = downsampleMean(obj.xptsClipped, obj.downsample);
            obj.QIDownsampled = qualityIndex(obj.dataDownsampled);

            % Normalize and average
            obj.dataFinal = roiNormAvg(obj.dataDownsampled, obj.bkgd);
        end

        function detectFeatures_SVD(obj, numPCs)
            if nargin == 2
                obj.numPCs = numPCs;
            end


        end

        function corrCoeffs = getClusterCorrelations(obj)
            corrCoeffs = zeros(numel(clustIdx), 1);
            for i = 1:numel(clustIdx)
                iCorr = corrcoef(obj.dataFinal(i,:), obj.clustAvg(clustIdx(i),:));
                corrCoeffs(i) = iCorr(1,2);
            end
        end
    end

    % Set core analysis parameters
    methods
        function setStimRegions(obj, ups, downs)
            obj.ups = ups;
            obj.downs = downs;
        end

        function setAnalysisRange(obj, framesFromStart, framesFromStop)
            if ~isempty(framesFromStart)
                obj.analysisRange(1) = framesFromStart;
            end
            if ~isempty(framesFromStop)
                obj.analysisRange(2) = framesFromStop;
            end
        end
    end
end