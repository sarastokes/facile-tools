function makeColormapSymmetric(ax)
    % MAKECOLORMAPSYMMETRIC
    %
    % Syntax:
    %   makeColormapSymmetric(ax)
    %
    % History:
    %   21Oct2021 - SSP
    % ---------------------------------------------------------------------
    if nargin < 1
        ax = gca;
    end

    set(ax, 'CLim', max(abs(get(ax, 'CLim'))) * [-1 1]);
