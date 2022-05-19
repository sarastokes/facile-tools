function S2 = convertMap_char2double(S)
    % CONVERTMAP_CHAR2DOUBLE
    %
    % Description:
    %   Converts containers.Map using #s as chars to one using double
    %
    % Syntax:
    %   S2 = convertMap_char2double(S)
    %
    % History:
    %   17Jan2022 - SSP
    % ---------------------------------------------------------------------


    S2 = containers.Map('KeyType', 'double', 'ValueType', 'any');
    k = S.keys;
    k2 = arrayfun(@str2double, k);
    k2 = sort(k2, 'ascend');

    for i = 1:numel(k2)
        S2(k2(i)) = S(num2str(k2(i)));
    end