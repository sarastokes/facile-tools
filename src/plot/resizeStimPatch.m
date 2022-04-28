function resizeStimPatch(axHandle, newLow, newHigh)
    % RESIZESTIMPATCH
    %
    % Description:
    %   Adjust stim patches sizing along the y-axis
    %
    % Syntax:
    %   resizeStimPatch(axHandle, newLow, newHigh)
    %
    % History:
    %   24Mar2022 - SSP
    % ---------------------------------------------------------------------
    
    currentYLim = axHandle.YLim;

    % Automatically assign if not provided
    if nargin == 1
        newLow = currentYLim(1)-0.1;
        newHigh = currentYLim(2)+0.1;
    end

    h = findall(axHandle, 'Tag', 'StimPatch');
    yData = h(1).YData;
    if ~isempty(newLow)
        yData(3:4) = newLow;
    end

    if nargin < 3 || isempty(newHigh)
        yData(1:2) = newHigh;
    end
    
    for i = 1:numel(h)
        h(i).YData = yData;
    end
    ylim(axHandle, currentYLim);
    drawnow;

