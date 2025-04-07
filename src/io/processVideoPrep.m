function [videoNames, p] = processVideoPrep(experimentDir, epochIDs, varargin)
% PROCESSVIDEOPREP
%
% Description:
%   Determines parameters and video names to be analyzed
%
% Syntax:
%   [videoNames, p] = processVideoPrep(experimentDir, epochIDs, varargin);
%
% Inputs:
%   experimentDir       char
%       Full file path to experiment folder
%   epochIDs            numeric
%       Which video IDs to process
% Optional key/value inputs:
%   ImagingSide         char ('left', 'right', 'full', 'top')
%       Which side was being imaged (default = 'full'). This determines how
%       and whether the image will be cropped. No cropping for "full"
%   RegistrationType    char ('strip', 'frame', 'none')
%       Which registration output to use (default = 'strip')
%   BackgroundValue    numeric (default = 0)
%       Noise floor value for the video to be subtracted.
%   Reflect             logical
%       Whether to reflect the video vertically (default = false). This is
%       used for data processed by 2022+ versions of ImageReg.
%   Channel             string (e.g., "vis", "ref")
%       Which channel to analyze (default = "vis"). This determines the
%       folder within the main experiment folder that is analyzed
%   UseFirst            logical (default = false)
%       If multiple registrations are found for a video, the last will be
%       used by default. If this is true, the first will be used instead.
%   UsingOldLEDs        logical
%       Whether data was generated using the old LED setup (default = false)
%   ExtraToken          string
%       Additional token to use when searching for files (default = [])
%
% Example:
%   [videoNames, p] = preprocessVideoPrep(...
%       "C:\Users\sarap\Desktop\MC00851_20220405", [2:10, 12:15],...
%       "ImagingSide", "left", "RegistrationType", "strip");
%
% See also:
%   PreprocessFunctionalImagingData
%
%
% Note:
%   - PreprocessFunctionalImagingData assumes outputs are named p, videoNames
%   - When running on Mac, all Dropbox/Drive files must be downloaded to
%     be recognized in the file listing
%   - Assumes standard file folder listing (e.g., "Vis" or "Ref" folders)
%     and assumes the string "vis_" is in each video name within the "Vis"
%     folder (and same for "Ref").
%
% History:
%   01Nov2021 - SSP
%   05Aug2022 - SSP - Updated for mac
%   26Oct2022 - SSP - Extra token option for Tyler's data
%   09Nov2022 - SSP - Added UseFirst option (false = use last)
%   13Dec2024 - SSP - Simplified FOV specification
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
    addParameter(ip, 'RegistrationType', 'frame',...
        @(x) ismember(x, {'frame', 'strip', 'none'}));
    addParameter(ip, 'ImageSize', [496, 360], @isnumeric);
    addParameter(ip, 'BackgroundValue', 0, @isnumeric);
    addParameter(ip, 'Reflect', false, @islogical);
    addParameter(ip, 'UseFirst', true, @islogical);
    addParameter(ip, 'Channel', 'vis', @ischar);
    addParameter(ip, 'UsingOldLEDs', false, @islogical);
    addParameter(ip, 'ExtraToken', [], @ischar);
    parse(ip, varargin{:});

    regType = ip.Results.RegistrationType;
    extraToken = ip.Results.ExtraToken;
    useFirst = ip.Results.UseFirst;

    % Keep parameters to pass to ImageJ-MATLAB script
    p = ip.Results;
    p.epochIDs = epochIDs;
    p.experimentDir = experimentDir;

    % Print parameters
    f = fieldnames(ip.Results);
    for i = 1:numel(f)
        fprintf('%s: ', f{i}); disp(ip.Results.(f{i}));
    end

    % Get the filenames in channel's folder (assumes "Vis" and/or "Ref")
    if strcmpi(p.Channel, 'vis')
        channelDir = fullfile(experimentDir, 'Vis');
    elseif strcmpi(p.Channel, 'ref')
        channelDir = fullfile(experimentDir, 'Ref');
    else
        channelDir = fullfile(experimentDir, p.Channel);
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
        if p.UsingOldLEDs  % This is old LED file naming scheme (pre-2022)
            videoStr = ['fs#', int2fixedwidthstr(epochIDs(i), 3)];
        else % Standard file naming post-2022
            if strcmpi(p.Channel, 'vis')
                videoStr = ['vis_', int2fixedwidthstr(epochIDs(i), 4)];
            elseif strcmpi(p.Channel, 'ref')
                videoStr = ['ref_', int2fixedwidthstr(epochIDs(i), 4)];
            else
                videoStr = ['_', int2fixedwidthstr(epochIDs(i), 4)];
            end
        end

        % Sort through the file names for the correct video
        if strcmpi(regType, 'none')
            % Unregistered doesn't contain "strip" or "frame"
            idx = find(contains(f, videoStr) & endsWith(f, '.avi') & ~contains(f, 'strip') & ~contains(f, 'frame'));
        else % Look for "strip" or "frame"
            idx = find(contains(f, videoStr) & endsWith(f, '.avi') & contains(f, regType));
        end

        % Filter by an extra token, if needed
        if ~isempty(extraToken)
            idx = find(contains(f, extraToken));
        end

        % Warn user if no video was found
        if isempty(idx)
            warning('PROCESSVIDEOPREP: epoch %u - registered video not found', epochIDs(i));
            videoNames(num2str(epochIDs(i))) = [];
            epochsNotFound = cat(2, epochsNotFound, epochIDs(i));
            continue
        end

        if numel(idx) > 1
            if p.UsingOldLEDs  % Special case for old LED config
                iNames = [];
                for j = 1:numel(idx)
                    iNames = cat(2, iNames, string(fullfile(channelDir, char(f(idx(j))))));
                end
                videoNames(num2str(epochIDs(i))) = iNames;
                continue
            else  % Warn user multiple videos were found and which was used
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