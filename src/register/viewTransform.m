function viewTransform(tform, x, y, varargin)
    % VIEWTRANSFORM
    %
    % Syntax:
    %   viewTransform(tform, x, y)
    %
    % History:
    %   15Sep2021 - SSP
    % ---------------------------------------------------------------------

    if numel(x) == 1
        x = linspace(1, x, 100);
    end

    if numel(y) == 1
        y = linspace(1, y, 100);
    end

    [X, Y] = meshgrid(x, y);
    newXY = transformPointsInverse(tform, [X(:), Y(:)]);

    figure(); hold on;
    plot(newXY(:, 1), newXY(:, 2), '.k', varargin{:});
    axis tight
