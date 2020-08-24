function roiKSDensity(rois, statNames, varargin)
    % ROIKSDENSITY
    %
    % Syntax:
    %   roiKSDensity(rois, statNames, varargin)
    %
    % Inputs:
    %   rois        struct
    %       Connected components from a detection function
    %   statNames   char or cell array of chars
    %       Statistic(s) to use (see regionprops)
    % Optional key/value inputs:
    %   Levels      integer (default = 10)
    %       Number of colors in density map
    % Additional key/value inputs are passed to ksdensity
    %
    % Examples:
    %   roiKSDensity(rois, {'MajorAxisLength', 'Eccentricity'});
    %   roiKSDensity(rois, 'MajorAxisLength', 'Function', 'cdf');
    %
    % See also:
    %   REGIONPROPS, LABELMATRIX, KSDENSITY
    % 
    % History:
    %   7Aug2020 - SSP
    %   23Aug2020 - SSP - Added colormap level control
    % --------------------------------------------------------------------

    ip = inputParser();
    ip.KeepUnmatched = true;
    ip.CaseSensitive = false;
    addParameter(ip, 'Levels', 10, @isnumeric);
    parse(ip, varargin{:});
    cmapLevels = ip.Results.Levels;

    if ~ischar(statNames)
        statOne = statNames{1}; statTwo = statNames{2};
        stats = regionprops('table', rois, statOne, statTwo);
        figure();
        ksdensity([stats.(statOne), stats.(statTwo)]);
        shading interp;
        colorbar();
        colormap(othercolor('Spectral10', cmapLevels));
        view(0, 90);
        xlabel(statOne); ylabel(statTwo);
        axis tight square
    else
        stats = regionprops('table', rois, statNames);
        figure(); hold on;
        [f, xi] = ksdensity(stats.(statNames), ip.Unmatched);
        h = plotg(xi, f, [], othercolor('Spectral10', numel(xi)));
        h.LineWidth = 2;
        xlabel(statNames);
        grid on;
        axis square 
        figPos(gcf, 0.5, 0.5);
    end