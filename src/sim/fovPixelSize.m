function x = fovPixelSize(fovWidth, varargin)
    % FOVPIXELSIZE
    %
    % Description:
    %   Get field of view pixel size in microns
    %
    % Syntax:
    %   x = fovPixelSize(fovWidth, varargin)
    %
    % Input:
    %   fovWidth        field of view width (degrees)
    % Optional key-value inputs:
    %   axialLength     in mm, default = 16.56 (from 838)
    %   pixelWidth      width of image in pixels (default = 496)
    %
    % Output:
    %   pixelSize       in microns
    %
    % History:
    %   18Feb2021 - SSP
    %   11Mar2021 - SSP - Moved from sim-sim, added pixelWidth input
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'axialLength', 16.56, @isnumeric);
    addParameter(ip, 'pixelWidth', 496, @isnumeric);
    parse(ip, varargin{:});
    axialLength = ip.Results.axialLength;

    % Get degrees per pixel
    degPerPixel = fovWidth / 496;
    % Convert to microns 
    micronsPerDegree = 291.2 * (axialLength / 24.2);
    x = micronsPerDegree * degPerPixel;
