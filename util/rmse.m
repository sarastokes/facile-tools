function y = rmse(a, b)
    % RMSE
    % 
    % Description:
    %   Calculates root mean squared error
    %
    % Syntax:
    %   y = rmse(a, b)
    %
    % History:
    %   ??? - SSP
    % ---------------------------------------------------------------------

    y = sqrt(mean((a(:) - b(:))) .^ 2);