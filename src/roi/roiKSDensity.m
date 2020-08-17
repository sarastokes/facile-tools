function roiKSDensity(rois, statNames, varargin)
    % ROIKSDENSITY
    %
    % Syntax:
    %   roiKSDensity(rois, statNames, varargin)
    %
    % Inputs:
    %   rois        struct
    %               Connected components from a detection function such as
    %               bwconncomp, detectMSERFeatures etc
    %   statNames   char or cell array of chars
    %               statistic(s) to use (see regionprops)
    % Additional inputs are passed to ksdensity
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
    % --------------------------------------------------------------------

    if ~ischar(statNames)
        statOne = statNames{1}; statTwo = statNames{2};
        stats = regionprops('table', rois, statOne, statTwo, varargin{:});
        figure();
        ksdensity([stats.(statOne), stats.(statTwo)]);
        shading interp;
        colorbar();
        colormap(othercolor('Spectral10', 10));
        view(0, 90);
        xlabel(statOne); ylabel(statTwo);
        axis tight square
    else
        stats = regionprops('table', rois, statNames);
        figure(); hold on;
        [f, xi] = ksdensity(stats.(statNames), varargin{:});
        h = plotg(xi, f, [], othercolor('Spectral10', numel(xi)));
        h.LineWidth = 2;
        xlabel(statNames);
        grid on;
        axis square 
        figPos(gcf, 0.5, 0.5);
    end