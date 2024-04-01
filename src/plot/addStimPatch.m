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
    %       Stimulus start and stop time(s). Each N row is a distinct patch
    % Additional key/value inputs are passed to "patch" like 'FaceColor'
    % and 'FaceAlpha'
    %
    % Outputs:
    %   h           patch handle(s)
    %       Handles to N stimulus patches
    %
    % History:
    %   29Dec2021 - SSP
    %   03Apr2022 - SSP - Added hideFromLegend option
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    addParameter(ip, 'FaceColor', [0.3 0.3 1], @isnumeric);
    addParameter(ip, 'FaceAlpha', 0.2, @isnumeric);
    addParameter(ip, 'HideFromLegend', true, @islogical);
    addParameter(ip, 'SendToBack', true, @islogical);
    parse(ip, varargin{:});

    hideFromLegend = ip.Results.HideFromLegend;
    S = ip.Results;
    S = rmfield(S, 'HideFromLegend');
    S = rmfield(S, 'SendToBack');
    
    hold(ax, 'on');
    yLimits = ylim(ax);
    maxVal = max(abs(yLimits)) + 1;
    
    h = [];
    for i = 1:size(stimWindow, 1)
        h = patch(...
            'XData', [stimWindow(i,:), fliplr(stimWindow(i,:))],... 
            'YData', maxVal * [1 1 -1 -1],...
            'Parent', ax,...
            'EdgeColor', 'none',...
            'Tag', 'StimPatch', S);
        if hideFromLegend
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if ip.Results.SendToBack
            uistack(h, 'bottom');
        end
    end
    
    ylim(ax, yLimits);
    if nargout > 0
        h = findall(ax, 'Tag', 'StimPatch');
    end