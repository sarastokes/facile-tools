function deleteZeroBar(ax)
    % DELETEZEROBAR
    %
    % Syntax:
    %   deleteZeroBar(ax)
    %
    % History:
    %   24Apr2022 - SSP
    % ---------------------------------------------------------------------
    
    if nargin == 0
        ax = gca;
    end
    delete(findall(ax, 'Tag', 'ZeroBar'));