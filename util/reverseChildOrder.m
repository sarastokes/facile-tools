function reverseChildOrder(axHandle)
    % REVERSECHILDORDER
    %
    % Description:
    %   Order of plot components determines which is on top. Flip it
    %
    % Syntax:
    %   reverseChildOrder(ax)
    %
    % Optional inputs:
    %   ax          axis handle
    %       Axis containing plot components (default = gca)
    %
    % History:
    %   11Jan2022 - SSP
    % ---------------------------------------------------------------------
    
    if nargin < 1
        axHandle = gca;
    end
    
    h = get(axHandle, 'Children');
    set(axHandle, 'Children', fliplr(flipud(h)));  %#ok