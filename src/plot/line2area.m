function areaObj = line2area(hObj, varargin)

    % Make sure hObj is a line
    if ~isa(hObj, 'matlab.graphics.primitive.Line')
        error('line2area:InvalidInput',...
            'Input must be a line handle, was %s', class(hObj));
    end

    ip = inputParser();
    ip.KeepUnmatched = true;
    addParameter(ip, 'Downsample', 0, @isnumeric);
    addParameter(ip, 'Norm', false, @islogical);
    parse(ip, varargin{:});

    xData = hObj.XData;
    yData = hObj.YData;


    if ip.Results.Downsample > 0
        xData = downsampleMean(xData, ip.Results.Downsample);
        yData = downsampleMean(yData, ip.Results.Downsample);
    end

    if ip.Results.Norm
        yData = roiNormPercentile(yData, 2);
    end

    areaObj = area(xData, yData);
    if ~isempty(fieldnames(ip.Unmatched))
        set(areaObj, ip.Unmatched);
    end

    delete(hObj);