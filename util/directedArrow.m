function h = directedArrow(p0, theta, varargin)
    % DIRECTEDARROW
    %
    % Syntax:
    %   h = directedArrow(p0, theta, varargin)
    %
    % See also:
    %   createLine, drawArrow
    %
    % History:
    %   10Apr2021 - SSP
    %   14Apr2021 - SSP - Added missing deg2rad conversion
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'Length', 2, @isnumeric);
    addParameter(ip, 'Width', 2, @isnumeric);
    addParameter(ip, 'Type', 1, @isnumeric);
    addParameter(ip, 'Scale', 10, @isnumeric);
    parse(ip, varargin{:});

    mag = ip.Results.Scale;
    L = ip.Results.Length;
    W = ip.Results.Width;
    lineType = ip.Results.Type;

    if ~isempty(theta)
        pts = createLine(deg2rad(theta));
        pts = (mag * pts) + [p0, p0];
    else
        pts = p0;
    end

    h = drawArrow(pts, L, W, lineType);

    set(h.body, ip.Unmatched);
    set(h.wing, ip.Unmatched);
