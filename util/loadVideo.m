function imStack = loadVideo(videoPath, varargin)
    % LOADVIDEO
    %
    % Syntax:
    %   imStack = loadVideo(videoPath)
    %
    % Inputs:
    %   videoPath           char
    %       file path and name of video (if empty, uses uigetfile)
    % Optional key/value inputs:
    %   side                char ['right']
    %       Side with GCaMP6 signal {'left', 'right', 'full'}
    %
    % History:
    %   03Nov2020 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Side', 'full', @ischar);
    parse(ip, varargin{:});
    
    if nargin == 0 || isempty(videoPath)
        [fileName, filePath, idx] = uigetfile({'*.avi'});
        if idx == 0
            imStack = [];
            return;
        end
        videoPath = [filePath, fileName];
    end

    v = VideoReader(videoPath);

    frame = im2double(readFrame(v));
    numFrames = v.Duration / v.CurrentTime;

    switch ip.Results.Side 
        case 'right'
            imWindow = floor(v.Width/2):v.Width;
        case 'left'
            imWindow = 1:ceil(v.Width/2);
        case 'full'
            imWindow = 1:v.Width;
    end

    imStack = zeros(v.Height, numel(imWindow), numFrames);
    imStack(:, :, 1) = frame(:, imWindow);

    for i = 2:numFrames
        frame = im2double(readFrame(v));
        imStack(:, :, i) = frame(:, imWindow);
    end 
    
    disp(videoPath);