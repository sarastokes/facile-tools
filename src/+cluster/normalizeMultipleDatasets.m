function varargout = normalizeMultipleDatasets(varargin)

    assert(nargout == nargin, 'Number of outputs must match number of inputs');

    for i = 1:nargout
        varargout{i} = roiNormPercentile(varargin{i});
    end