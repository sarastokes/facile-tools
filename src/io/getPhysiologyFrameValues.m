function [T, frameRate] = getPhysiologyFrameValues(experimentDir, epochID)
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
    %   11Feb2022 - SSP
    % ---------------------------------------------------------------------
    
    refDir = [experimentDir, filesep, 'Ref'];

    refFiles = ls(refDir);
    refFiles = deblank(string(refFiles));

    refFiles = refFiles(~contains(refFiles, 'motion') ...
        & contains(refFiles, 'ref') & endsWith(refFiles, 'csv'));
    ind = find(contains(refFiles, ['ref_', int2fixedwidthstr(epochID, 4)]));
   
    if isempty(ind)
        error('Could not find %u in %s', epochID, refDir);
    end
    epochFile = [refDir, filesep, char(refFiles(ind))];

    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    T = readtable(epochFile);
    T(:,2) = [];  % Doesn't read in right
    T.Properties.VariableNames = {'Frame', 'TimeStamp', 'FrameInterval', 'StimDelay', 'StimIdx', 'Background', 'StimLocX', 'StimLocY', 'Tracking', 'Status'};
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');


    % Add column for epoch-specific timing
    x = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
    T.Timing = x / 1000;
    
    % The final frames in the stimulus log weren't actually saved
    % Use the video size to determine which frames are relevant
    videoPath = strrep(epochFile, '.csv', '.avi');
    v = VideoReader(videoPath);
    numFrames = round(v.Duration / v.CurrentTime);

    % Remove extra frames and also the blank frames
    T = T(2:numFrames, :);

    frameRate = 1000/mean(T.TimeInterval);
    fprintf('Frame rate for %u was %.3f\n', epochID, frameRate);