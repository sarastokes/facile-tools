function toggleProperty(h, propName)
    % TOGGLEPROPERTY
    %
    % Syntax:
    %   toggleProperty(h, propName)
    % 
    % History:
    %   23Jan2020 - SSP
    % ---------------------------------------------------------------------

    if strcmp(h.(propName), 'off')
        h.(propName) = 'on';
    elseif strcmp(h.(propName), 'on')
        h.(propName) = 'off';
    end