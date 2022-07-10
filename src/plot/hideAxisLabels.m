function hideAxisLabels(axHandle, whichAxes)
    % HIDEAXISLABELS
    %
    % Syntax:
    %   hideAxisLabels(axHandle, whichAxes)
    %
    % Inputs:
    %   axHandle        axis handle
    %       Axis to hide labels (default = gca)
    %   whichAxes       char
    %       Which axes to hide labels for ('x', 'y', 'z', 'xy', 'xyz', etc)
    %
    % History:
    %   26May2022 - SSP
    % ---------------------------------------------------------------------
    if nargin == 0 || isempty(axHandle)
        axHandle = gca;
    end

    if nargin < 2
        set(axHandle, 'XTickLabels', {}, 'YTickLabels', {});
        return;
    end

    if contains(whichAxes, 'x')
        set(axHandle, 'XTickLabels', {});
    end

    if contains(whichAxes, 'y')
        set(axHandle, 'YTickLabels', {});
    end

    if contains(whichAxes, 'z')
        set(axHandle, 'ZTickLabels', {});
    end