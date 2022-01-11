function h = addStimPatch(ax, stimWindow, varargin)
    % ADDSTIMPATCH
    %
    % Description:
    %   Add shading to region(s) where stimulus was displayed
    %
    % Syntax:
    %   h = addStimPatch(ax, stimWindow, varargin)
    %
    % Inputs:
    %   ax          axis handle
    %       Where to add the stim patches
    %   stimWindow  array [N x 2]
    %       Stimulus start and stop time(s). Each row is a distinct patch
    %
    % Outputs:
    %   h           patch handle(s)
    %       Handles to N stimulus patches
    %
    % History:
    %   29Dec2021 - SSP
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    addParameter(ip, 'FaceColor', [0.3 0.3 1], @isnumeric);
    addParameter(ip, 'FaceAlpha', 0.2, @isnumeric);
    parse(ip, varargin{:});
    
    hold(ax, 'on');
    yLimits = ylim(ax);
    maxVal = max(abs(yLimits)) + 1;
    
    h = [];
    for i = 1:size(stimWindow, 1)
        patch(...
            'XData', [stimWindow(i,:), fliplr(stimWindow(i,:))],... 
            'YData', maxVal * [1 1 -1 -1],...
            'Parent', ax,...
            'EdgeColor', 'none',...
            'Tag', 'StimPatch', ip.Results);
    end
    
    ylim(ax, yLimits);
    
    if nargout > 0
        h = findall(ax, 'Tag', 'StimPatch');
    end