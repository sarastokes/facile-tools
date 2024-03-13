function out = makeGroupingVariable(name1, N1, name2, N2, varargin)

    arguments
        name1       (1,1)   string
        N1          (1,1)   double {mustBeInteger}
        name2       (1,1)   string
        N2          (1,1)   double {mustBeInteger}
    end

    arguments (Repeating)
        varargin
    end

    out = repmat(name1, N1, 1);
    out = [out; repmat(name2, N2, 1)];
    if nargin == 4
        return
    end

    for i = 1:2:length(varargin)
        name = convertCharsToStrings(varargin{i});
        N = varargin{i+1};
        out = [out; repmat(name, N, 1)]; %#ok<AGROW>
    end
