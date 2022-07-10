function [ax, plotOffset] = addMultiSubplot(nRow, nCol, plotOffset, nWide)
    % ADDMULTISUBPLOT
    %
    % Description:
    %   Utility function for making many multiplots
    %
    % Syntax:
    %   [ax, plotOffset] = addMultiSubplot(nRow, nCol, plotOffset, nWide)
    %
    % History:
    %   11Jun2022 - SSP
    % ---------------------------------------------------------------------

    if nargin < 4
        nWide = 1;
    end

    if nWide == 1
        ax = subplot(nRow, nCol, plotOffset+1);
    else
        ax = subplot(nRow, nCol, plotOffset+1:plotOffset+nWide);
    end
    hold(ax, 'on');

    % Increment the count 
    plotOffset = plotOffset + nWide;
