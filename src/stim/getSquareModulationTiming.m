function [ups, downs] = getSquareModulationTiming(T, whichLED, outputFrames)
    % GETSQUAREMODULATIONTIMING
    %
    % Syntax:
    %   [ups, downs] = getSquareModulationTiming(T, whichLED, outputFrames)
    %
    % Inputs:
    %   T       table
    %       Frame/LED table
    % Optional inputs:
    %   whichLED        numeric (default = 1)
    %       1 = red, 2 = green, 3 = blue, 4 = all summed together
    %   outputFrames    logical (default = false)
    %       Whether to output frame #s instead of seconds
    %
    % See also:
    %   readJsonLED, ao.core.DatasetLED2/loadFrameTraces
    %
    % History:
    %   17Feb2022 - SSP
    % ---------------------------------------------------------------------
    if nargin < 3
        outputFrames = false;
    end

    if nargin < 2
        whichLED = 1;
    end
        
    switch whichLED
        case 1  % Red
            stim = T.R;
        case 2  % Green
            stim = T.G;
        case 3  % Blue
            stim = T.B;
        case 4  % All
            stim = T.R + T.G + T.B;
    end

    bkgd = stim(1);
    changes = [0; diff(stim)];

    idx = find(changes ~= 0);
    idx = [idx; height(T)];

    ups = [];
    downs = [];
    for i = 1:numel(idx)-1
        newValue = stim(idx(i));
        if newValue > bkgd
            ups = cat(1, ups, [idx(i) idx(i+1)-1]);
        elseif newValue < bkgd
            downs = cat(1, downs, [idx(i) idx(i+1)-1]);
        end
    end

    if ~isempty(ups)
        if outputFrames
            if ~istimetable(T)
                ups = T.Frame(ups);
            end
        else
            if istimetable(T)
                ups = seconds(T.Time(ups));
            else
                ups = T.Timing(ups);
            end
        end

        ups = reshape(ups, [numel(ups)/2, 2]);
    end
    
    if ~isempty(downs)
        if outputFrames
            if ~istimetable(T)
                downs = T.Frame(downs);
            end
        else
            if istimetable(T)
                downs = seconds(T.Time(ups));
            else
                downs = T.Timing(downs);
            end
        end
        downs = reshape(downs, [numel(downs)/2, 2]);
    end
