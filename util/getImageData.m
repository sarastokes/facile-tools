function data = getImageData(parentHandle)
    % GETIMAGEDATA
    %
    % Syntax:
    %   data = getImageData(parentHandle);
    %
    % History:
    %   19Dec2021 - SSP
    % ---------------------------------------------------------------------

    if nargin < 1
        parentHandle = gca;
    end

    data = get(findobj(parentHandle, 'Type', 'Image'), 'CData');