function x = getX(nFrames, frameRate)
    % GETX
    % 
    % Description:
    %   Get x-axis in seconds from the number of frames 
    %
    % Syntax:
    %   x = getX(nFrames, frameRate)
    %
    % Inputs:
    %   nFrames         integer
    %       Number of frames present
    %   frameRate       double
    %       Hz (default = 25)
    % Output:
    %   x               array
    %       Timing in seconds for each frame
    %
    % History:
    %   24Dec2020 - SSP
    % ---------------------------------------------------------------------
    
    if nargin < 2 
        frameRate = 25;
    end

    frameTime = 1 / frameRate;

    x = 1:nFrames;
    x = frameTime * x + frameTime;