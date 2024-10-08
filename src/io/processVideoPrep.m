function [videoNames, p] = processVideoPrep(experimentDir, epochIDs, varargin)
% PROCESSVIDEOPREP
%
% Syntax:
%   [videoNames, p] = processVideoPrep(experimentDir, epochIDs, varargin);
%
% Note:
%   - When running on Mac, all Dropbox/Drive files must be downloaded to
%     be recognized in the file listing
%   - Assumes standard file folder listing (e.g., "Vis" or "Ref" folders)
%     and assumes the string "vis_" is in each video name within the "Vis"
%     folder (and same for "Ref"). 
%
% History:
%   01Nov2021 - SSP
%   05Aug2022 - SSP - Updated for mac
%   26Oct2022 - SSP - Extra header
%   09Nov2022 - SSP - Added UseFirst option (false = use last)
% -------------------------------------------------------------------------

    % Ensure experiment folder path ends with a filesep
    experimentDir = convertStringsToChars(experimentDir);
    if experimentDir(end) ~= filesep
        experimentDir = [experimentDir, filesep];
    end

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'ImagingSide', 'full',...
        @(x) ismember(x, {'left', 'right', 'right_smallFOV', 'full', 'top'}));
    addParameter(ip, 'FieldOfView', [496 360], @(x) isnumeric(x) & numel(x) == 2);
    addParameter(ip, 'RegistrationType', 'frame',...
        @(x) ismember(x, {'frame', 'strip', 'none'}));
    addParameter(ip, 'ExtraHeader', [], @ischar);
    addParameter(ip, 'Reflect', false, @islogical);
    addParameter(ip, 'UsingLEDs', false, @islogical);
    addParameter(ip, 'UseFirst', true, @islogical);
    addParameter(ip, 'Channel', "vis", @(x) ismember(x, ["vis", "ref", "custom"]));
    addParameter(ip, 'BackgroundRegion', [], @(x) isnumeric(x) && numel(x) == 4);
    addParameter(ip, 'BackgroundValue', 0, @isnumeric);
    parse(ip, varargin{:});

    regType = ip.Results.RegistrationType;
    usingLEDs = ip.Results.UsingLEDs;
    extraHeader = ip.Results.ExtraHeader;
    useFirst = ip.Results.UseFirst;
    whichChannel = ip.Results.Channel;
    backgroundRegion = ip.Results.BackgroundRegion; %#ok<NASGU>

    % Keep parameters to pass back to ImageJ-MATLAB script
    p = ip.Results;
    p.epochIDs = epochIDs;
    p.experimentDir = experimentDir;
    % Print parameters
    f = fieldnames(ip.Results);
    for i = 1:numel(f)
        fprintf('%s: ', f{i}); disp(ip.Results.(f{i}));
    end

    % Get the filenames in channel's folder (assumes "Vis" and/or "Ref")
    if whichChannel == "vis"
        channelDir = fullfile(experimentDir, 'Vis');
    elseif whichChannel == "ref"
        channelDir = fullfile(experimentDir, 'Ref');
    elseif whichChannel == "custom"
        channelDir = fullfile(experimentDir);
    end

    if ispc
        f = ls(channelDir);
        f = deblank(string(f));
    else  % For Mac
        d = dir(channelDir);
        f = arrayfun(@(x) string(x.name), d, 'UniformOutput', true);
    end

    % Get the video names and track which epochs are not found
    videoNames = containers.Map();
    epochsNotFound = [];

    for i = 1:numel(epochIDs)
        if usingLEDs  % This is old LED file naming scheme (pre-2022)
            videoStr = ['fs#', int2fixedwidthstr(epochIDs(i), 3)];
        else % Standard file naming post-2022
            if whichChannel == "vis"
                videoStr = ['vis_', int2fixedwidthstr(epochIDs(i), 4)];
            elseif whichChannel == "ref"
                videoStr = ['ref_', int2fixedwidthstr(epochIDs(i), 4)];
            else
                videoStr = ['_', int2fixedwidthstr(epochIDs(i), 4)];
            end
        end

        if ~isempty(extraHeader)
            videoStr = [extraHeader, videoStr]; %#ok<AGROW>
        end

        % Sort through the file names for the correct video
        if strcmp(regType, 'none')  
            % Unregistered doesn't contain "strip" or "frame"
            idx = find(contains(f, videoStr) & endsWith(f, '.avi') & ~contains(f, 'strip') & ~contains(f, 'frame'));
        else % Look for "strip" or "frame"
            idx = find(contains(f, videoStr) & endsWith(f, '.avi') & contains(f, regType));
        end
        
        if isempty(idx)
            warning('PROCESSVIDEOPREP: epoch %u - registered video not found', epochIDs(i));
            videoNames(num2str(epochIDs(i))) = [];
            epochsNotFound = cat(2, epochsNotFound, epochIDs(i));
            continue
        end

        if numel(idx) > 1
            if usingLEDs
                iNames = [];
                for j = 1:numel(idx)
                    iNames = cat(2, iNames, string(fullfile(channelDir, char(f(idx(j))))));
                end
                videoNames(num2str(epochIDs(i))) = iNames;
                continue
            else
                if useFirst
                    warning('PROCESSVIDEOPREP: epoch %u - found %u registered videos, using the first',...
                        epochIDs(i), numel(idx));
                    idx = idx(1);
                else
                    warning('PROCESSVIDEOPREP: epoch %u - found %u registered videos, using the last',...
                        epochIDs(i), numel(idx));
                    idx = idx(end);
                end

            end
        end
        videoNames(num2str(epochIDs(i))) = string(fullfile(channelDir, char(f(idx))));
    end

    if ~isempty(epochsNotFound)
        fprintf('%u epochs not found\n', numel(epochsNotFound));
    end