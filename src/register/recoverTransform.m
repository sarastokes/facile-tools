function [rotFac, scaleFac] = recoverTransform(tform)
    % RECOVERTRANSFORM
    %
    % Syntax:
    %   [rotFac, scaleFac] = recoverTransform(tform);
    %
    % History:
    %   17Dec2021

    u = [0 1];
    v = [0 0];
    [x, y] = transformPointsForward(tform, u, v);
    dx = x(2) - x(1);
    dy = y(2) - y(1);
    rotFac = (180/pi) * atan2(dy, dx);
    scaleFac = 1 / sqrt(dx^2 + dy^2);