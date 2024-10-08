function plotFirstN(data, N, varargin)

    ip = inputParser();
    ip.KeepUnmatched = true;
    ip.CaseSensitive = false;
    addParameter(ip, 'IDs', []);
    addParameter(ip, 'X', 1:size(data, 2), @isnumeric);
    addParameter(ip, 'Offset', 0, @isnumeric);
    addParameter(ip, 'CMap', othercolor('Spectral10', N), @isnumeric);
    parse(ip, varargin{:});

    X = ip.Results.X;
    offset = ip.Results.Offset;
    IDs = ip.Results.IDs;
    co = ip.Results.CMap;

    if isempty(IDs)
        IDs = 1:(N+offset);
    end

    
    figure(); hold on;
    for i = 1:N
        if isempty(IDs)
            tag = [];
        elseif ~istext(IDs(i))
            tag = num2str(IDs(i));
        else
            tag = IDs(i);
        end
        plot(X, data(i+offset,:),...
            'DisplayName', num2str(tag),...
            'Color', co(i,:), ip.Unmatched);
    end
    legend("Location", "eastoutside");