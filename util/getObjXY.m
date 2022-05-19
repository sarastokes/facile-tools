function [x, y] = getObjXY(gObj)
    % GETOBJXY
    %
    % Description:
    %   Return XData and YData of graphics object 
    %
    % Syntax:
    %   [x, y] = getObjXY(gObj)
    %   xy = getObjXY(gObj)
    %
    % History:
    %   11May2022 - SSP
    % ---------------------------------------------------------------------

    if nargin == 0
        gObj = gco;
    end

    if nargout == 2
        x = gObj.XData';
        y = gObj.YData';
    elseif nargout == 1
        x = [gObj.XData; gObj.YData]';
    end