function h = xyplot(data, varargin)
    % XYPLOT
    %
    % Description:
    %   Wrapper for plot that splits x and y data
    %
    % Syntax:
    %   h = xyplot(data)
    %
    % History:
    %   09Sep2021 - SSP
    % ---------------------------------------------------------------------

    if size(data, 2) ~= 2 && size(data, 1) == 2
        data = data';
    end

    h = plot(data(:, 1), data(:, 2), varargin{:});