function [signalsD, xptsD] = roiDownsample(signals, nPts, method, opts)
% ROIDOWNSAMPLE
%
% Syntax:
%   signalsD = roiDownsample(signals, nPts)
%   signalsD = roiDownsample(signals, nPts, method)
%   [signalsD, xptsD] = roiDownsample(signals, nPts, method, sampleRate)
%
% See also:
%   DOWNSAMPLEMEAN, DOWNSAMPLESUM
% --------------------------------------------------------------------------

    arguments
        signals                 double
        nPts            (1,1)   double  {mustBeInteger}
        method          (1,1)   string  {mustBeMember(method, ["mean", "median", "sum"])} = "mean"
        opts.X          (1,:)   double  = 1:size(signals, 2)
        opts.SampleRate (1,1)   double = 25
    end

    if ndims(signals) > 3
        error('roiDownsample:InvalidDimensions',...
            'Signals with more than 3 dimensions are not supported');
    end

    T0 = size(signals, 2);
    lastPoints = nPts:nPts:T0;

    switch method
        case "mean"
            out = arrayfun(@(x) mean(signals(:,x-nPts+1:x,:), 2), lastPoints,...
                'UniformOutput', false);
        case "sum"
            out = arrayfun(@(x) sum(signals(:,x-nPts+1:x,:), 2), lastPoints,...
                'UniformOutput', false);
        case "median"
            out = arrayfun(@(x) median(signals(:,x-nPts+1:x,:), 2), lastPoints,...
                'UniformOutput', false);
    end
    signalsD = cell2mat(out);

    if nargout == 2
        if isempty(opts.X)
            xpts = 1/opts.SampleRate:1/opts.SampleRate:length(signals)/opts.SampleRate;
        else
            xpts = opts.X;
        end
        xptsD = downsampleMean(xpts, nPts);
    end


