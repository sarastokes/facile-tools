function [videoNames, p] = processVideoPrep(experimentDir, epochIDs, varargin)
    % PROCESSVIDEOPREP
    %
    % Syntax:
    %   [videoNames, p] = processVideoPrep(experimentDir, epochIDs,
    %       varargin);
    %
    % Note:
    %   When running on Mac, all Dropbox/Drive files must be downloaded to
    %   be recognized in the file listing
    %
    % History:
    %   01Nov2021 - SSP 
    %   05Aug2022 - SSP - Updated for mac
    %   26Oct2022 - SSP - Extra header
    % ---------------------------------------------------------------------

    if experimentDir(end) ~= filesep 
        experimentDir = [experimentDir, filesep];
    end

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'ImagingSide', 'full',...
        @(x) ismember(x, {'left', 'right', 'right_smallFOV', 'full', 'top'}));
    addParameter(ip, 'RegistrationType', 'frame',... 
        @(x) ismember(x, {'frame', 'strip', 'none'}));
    addParameter(ip, 'ExtraHeader', [], @ischar);
    addParameter(ip, 'Reflect', false, @islogical);
    addParameter(ip, 'UsingLEDs', false, @islogical);
    parse(ip, varargin{:});
    
    regType = ip.Results.RegistrationType;
    usingLEDs = ip.Results.UsingLEDs;
    extraHeader = ip.Results.ExtraHeader;

    % Keep parameters to pass back to ImageJ-MATLAB script
    p = ip.Results;
    p.epochIDs = epochIDs;
    p.experimentDir = experimentDir;
    % Print parameters
    f = fieldnames(ip.Results);
    for i = 1:numel(f)
        fprintf('%s: ', f{i}); disp(ip.Results.(f{i}));
    end

    % Get all the filenames in 'Vis' folder
    visDir = fullfile(experimentDir, 'Vis');
    if ispc
        f = ls(visDir);
        f = deblank(string(f));
    else
        d = dir(visDir);
        f = arrayfun(@(x) string(x.name), d, 'UniformOutput', true);
    end

    % Get the video names
    videoNames = containers.Map();
    % Track which epochs were not found
    epochsNotFound = [];

    for i = 1:numel(epochIDs)
        if usingLEDs
            videoStr = ['fs#', int2fixedwidthstr(epochIDs(i), 3)];
        else
            videoStr = ['vis_', int2fixedwidthstr(epochIDs(i), 4)];
        end

        if ~isempty(extraHeader)
            videoStr = [extraHeader, videoStr]; %#ok<AGROW> 
        end

        % Get the registered video
        if strcmp(regType, 'none')
            idx = find(contains(f, videoStr) & endsWith(f, '.avi') & ~contains(f, 'strip') & ~contains(f, 'frame'));
        else
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
                    iNames = cat(2, iNames, string(fullfile(visDir, char(f(idx(j))))));
                end
                videoNames(num2str(epochIDs(i))) = iNames;
                continue
            else
                warning('PROCESSVIDEOPREP: epoch %u - found %u registered videos, using the first',... 
                    epochIDs(i), numel(idx));
                idx = idx(1);
            end
        end
        videoNames(num2str(epochIDs(i))) = string(fullfile(visDir, char(f(idx))));
    end
    
    if ~isempty(epochsNotFound)
        fprintf('%u epochs not found\n', numel(epochsNotFound));
    end

