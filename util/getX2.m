function x = getX2(nFrames, frameRate)
    % GETX2
    %
    % Description:
    %   Get x-axis in seconds from the number of frames, omitting 1st frame
    %
    % Syntax:
    %   x = getX2(nFrames, frameRate)
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
    % See also:
    %   GETX
    %
    % History:
    %   12Feb2022 - SSP
    % ---------------------------------------------------------------------
    
    x = getX(nFrames+1, frameRate);
    x(1) = [];