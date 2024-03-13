function [h, fans] = populationFanChart(xData, yData, opts)
    
    arguments
        xData           (1,:)   double 
        yData           (:,:)   double 
        opts.Values     (1,:)   {mustBeInRange(opts.Values, 0, 100)} = 5:5:95
        opts.Cmap               double                               = []
        opts.Alpha      (1,1)   {mustBeInRange(opts.Alpha, 0, 1)}    = 1
        opts.Median     (1,1)   logical                              = true
        opts.Parent             {mustBeScalarOrEmpty}                = []
    end

    if ~isempty(opts.Parent)
        opts.Parent = axes('Parent', figure());
        hold(opts.Parent, 'on');
    end

    if ~isempty(opts.Cmap)
        assert(size(opts.Cmap, 1) >= ceil(numel(opts.Values)/2),...
            sprintf('Custom colormap must have at least %u rows', numel(opts.Values)));
    end

    if opts.Median
        summaryMode = 'median';
    else
        summaryMode = 'mean';
    end

    [h, fans] = fanchart(xData, yData', summaryMode, opts.Values,...
        'alpha', opts.Alpha);
    if ~isempty(opts.Cmap)
        for i = numel(fans):-1:1
            set(fans(i), 'FaceColor', opts.Cmap(i,:), 'EdgeColor', opts.Cmap(i,:));
        end
    end