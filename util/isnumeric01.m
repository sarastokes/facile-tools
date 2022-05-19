function tf = isnumeric01(val)
    % ISNUMERIC01
    %
    % Description:
    %   Convenience function to determine if input is between 0 and 1
    %
    % Syntax:
    %   tf = isnumeric01(val)
    %
    % History:
    %   10May2022 - SSP
    % ---------------------------------------------------------------------

    if ~isnumeric(val)
        tf = false;
        return
    end

    if val < 0 || val > 1 
        tf = false;
        return
    end

    tf = true;
