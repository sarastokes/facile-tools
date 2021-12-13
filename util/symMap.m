function h = symMap(im, varargin)
    % SYMMAP
    %
    % Syntax:
    %   symMap(im)
    %
    % Inputs:
    %   im          [x y] matrix
    % Optional key/value inputs:
    %   Sigma     numeric
    %       value for imgaussfilt (default = none)
    %   ParentHandle    axes handle
    %       axis to plot to (default = new figure and new axis)
    %
    % History:
    %   06Oct2021 - SSP
    %   20Oct2021 - SSP - Added output handle to image
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    addParameter(ip, 'Sigma', [], @isnumeric);
    addParameter(ip, 'ParentHandle', [], @ishandle);
    parse(ip, varargin{:});
    
    if isempty(ip.Results.ParentHandle)
        ax = axes('Parent', figure());
    else
        ax = ip.Results.ParentHandle;
    end
    
    if ~isempty(ip.Results.Sigma)
        im = imgaussfilt(im, ip.Results.Sigma);
    end
    h = imagesc(ax, im);
    maxVal = max(abs(get(ax, 'Clim')));
    set(ax, 'Clim', [-maxVal, maxVal]);
    colormap(ax, gray);
    axis(ax, 'equal', 'tight', 'off');
    