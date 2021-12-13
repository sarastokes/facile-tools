function y = groupMean(data, groups)
    % GROUPMEAN
    %
    % Description:
    %   Wrapper for splitapply with catch for issue computing group means
    %
    % Syntax:
    %   y = groupMean(data, groups)
    %
    % Inputs:
    %   data        [N x S]
    %       Matrix where each row is a different sample
    %   groups      [N x 1]
    %       Array with group indices for each sample
    %
    % Outputs:
    %   y           Group means where each row is a different group index
    %
    % See also:
    %   SPLITAPPLY
    %
    % History:
    %   05Dec2021 - SSP
    % ---------------------------------------------------------------------

    try  
        y = splitapply(fcn, data, groups);
    catch
        y = zeros(numel(unique(groups)), size(data, 2));
        for i = 1:numel(unique(groups))
            y(i, :) = mean(data(groups == i, :), 1);
        end
    end