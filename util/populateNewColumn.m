function T = populateNewColumn(T, colName, colValue)
    % POPULATENEWCOLUM
    % 
    % Syntax:
    %   T = populateNewColumn(T, colName, colValue)
    %
    % History:
    %   03Apr2022 - SSP
    % ---------------------------------------------------------------------
    T.(colName) = repmat(colValue, [height(T), 1]);

    