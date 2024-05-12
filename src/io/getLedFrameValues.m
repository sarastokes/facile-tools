function [T, frameRate] = getLedFrameValues(experimentDir, epochID, videoPath)
% GETLEDFRAMEVALUES
%
% Syntax:
%   [T, frameRate] = getLedFrameValues(experimentDir, epochID)
%
% Inputs:
%   experimentDir       char
%       File path to main experiment folder (the one containing 'Ref')
%   epochID             integer
%       Which video you want to get the frame values for
%
% Outputs:
%   T                   table
%       Table containing LED information for each frame
%   frameRate           double
%       1/average frame time, Hz
%
% Note:
%   Extra unsaved frames and the first blank frame rows are omitted
%
% History:
%   11Feb2022 - SSP - Moved out from ao.core.Dataset
%   01May2024 - SSP - Added support for using analysis tiffs for frame count
% --------------------------------------------------------------------------

    if nargin < 3
        videoPath = [];
    end

    refDir = [experimentDir, filesep, 'Ref'];

    refFiles = dir(refDir);
    ind = find(arrayfun(@(x) contains(x.name, 'csv') & contains(x.name, 'ref')...
        & ~contains(x.name, 'motion') & contains(x.name, ['ref_', int2fixedwidthstr(epochID, 4)]), refFiles));

    if isempty(ind)
        error('Could not find %u in %s', epochID, refDir);
    end
    epochFile = [refDir, filesep, refFiles(ind).name];

    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    T = readtable(epochFile);
    T.Properties.VariableNames = {'Frame', 'TimeInterval', 'TimeStamp', 'R', 'G', 'B'};
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Add column for epoch-specific timing
    x = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
    T.Timing = x / 1000;

    % The final frames in the stimulus log weren't actually saved
    % Use the video size to determine which frames are relevant
    try
        if isempty(videoPath)
            videoPath = strrep(epochFile, '.csv', '.avi');
            if ~exist(videoPath, 'file')
                videoPath = strrep(epochFile, '.csv', 'O.avi');
            end
            if ~exist(videoPath, 'file')
                videoPath = fullfile(experimentDir, 'Analysis', 'Videos',...
                    sprintf('vis_%s.tif', int2fixedwidthstr(epochID,4)));
            end
        end
        if endsWith(videoPath, '.avi')
            v = VideoReader(videoPath);
            numFrames = v.NumFrames;
        else
            TS = readTiffStack(videoPath);
            numFrames = size(TS, 3);
        end
    catch ME
        warning("getLedFrameValues:InvalidFile", "%s: %s", ME.message, videoPath);
        numFrames = height(T);
    end

    % Remove extra frames and also the blank frames
    T = T(2:numFrames, :);

    frameRate = 1000/mean(T.TimeInterval);
    fprintf('Frame rate for %u was %.3f\n', epochID, frameRate);