function deleteScaleBars(axHandle)
    % DELETESCALEBARS
    %
    % Description:
    %   Delete all tagged bars in axis
    %
    % Syntax:
    %   deleteScaleBars(axHandle)
    %
    % History:
    %   30Apr2022 - SSP
    % ---------------------------------------------------------------------

    if nargin == 0
        axHandle = gca;
    end

    delete(findall(axHandle, 'Tag', 'ScaleBar'));
    delete(findall(axHandle, 'Tag', 'CalibrationBar'));
    