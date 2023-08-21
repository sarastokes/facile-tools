function [avgTrace, stdTrace, x] = plotPopulationAverage(x, data, opts, shadeProps, lineProps)
%
% Syntax:
%   [h, avgTrace] = plotPopulationAverage(x, data)
%   plotPopulationAverage(x, data, opts, shadeProps, lineProps)
%

    arguments 
        x 
        data 
        opts.Shade                  logical = false 
        opts.Norm                   logical = false
        opts.Decimate               double  = 0
        opts.Parent                         = []
        shadeProps.lineProps                = '-k'
        shadeProps.transparent      logical = true 
        shadeProps.patchSaturation  double  = 0.22
        lineProps.?matlab.graphics.chart.primitive.Line
    end

    if ndims(data) == 3
        data = squeeze(mean(data, 3));
    end

    avgTrace = mean(data, 1);
    stdTrace = std(data, [], 1);  % check

    if opts.Norm  
        avgTrace = avgTrace / max(abs(avgTrace));
    end

    if opts.Decimate > 0
        avgTrace = decimate(avgTrace, opts.Decimate);
        stdTrace = decimate(stdTrace, opts.Decimate);
        x = linspace(min(x), max(x), numel(avgTrace));
    end

    if isempty(opts.Parent)
        ax = axes('Parent', figure());
        hold on; grid on;
        xlim([min(x)+1.5, max(x)-1.5]);
        xlabel('Time (s)');
        figPos(gcf, 0.7, 0.7);
    end

    if opts.Shade
        propArgs = namedargs2cell(shadeProps);
        h = shadedErrorBar(x, avgTrace, stdTrace, propArgs{:});
    else
        propArgs = namedargs2cell(lineProps);
        h = plot(x, avgTrace, propArgs{:});
    end
