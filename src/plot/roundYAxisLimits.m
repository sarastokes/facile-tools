function newY = roundYAxisLimits(ax, roundToNearest)
    % ROUNDYAXISLIMITS
    % 
    % Syntax:
    %   roundYAxisLimits(ax, roundToNearest)
    %
    % Inputs:
    %   ax          Axis handle
    % Optional inputs:
    %   roundToNearest      float array (default = [1 1])
    %       First input is applied to lower limit, 2nd to upper
    %       For 0.25, ylimits will round up to nearest 0.25
    %       If only 1 input, will be applied to both + and - limits
    %
    % See also:
    %   MAKEYAXISSYMMETRIC
    %
    % History:
    %   31Dec2021 - SSP
    % ----------------------------------------------------------------

    if nargin == 0
        ax = gca;
    else
        assert(isa(ax, 'matlab.graphics.axis.Axes'),...
            'Input must be axes handle!');
    end

    if nargin < 2 || isempty(roundToNearest)
        roundToNearest = 1;
    end

    if numel(roundToNearest) == 1
        roundToNearest = [roundToNearest, roundToNearest];
    end

    % Get existing axis limits
    x = get(ax, 'XLim');
    axis(ax, 'tight');
    y = get(ax, 'YLim');
    
    newY = y;
  
    % Round
    ind = 1 ./ roundToNearest;
    newY(1) = floor(ind(1) * newY(1)) / ind(1);
    newY(2) = ceil(ind(2) * newY(2)) / ind(2);

    % Ensure 0 is in the axis
    if newY(1) > 0
        newY(1) = 0;
    end

    if newY(2) < 0
        newY(2) = 0;
    end

    % Keep old x-axis, apply new y-axis
    ylim(ax, newY);
    xlim(ax, x);
