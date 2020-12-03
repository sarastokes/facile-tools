function [stats, L2] = roiColorByStat(rois, statName, varargin)
    % ROICOLORBYSTAT
    %
    % Description:
    %   Replaces locations of ROIs with relevant stat and plots
    %
    % Syntax:
    %   L = roiColorByStat(rois, statName);
    %
    % Inputs:
    %   rois        struct or 2D matrix
    %               Connected components from detection fcn OR label matrix
    %   statName    char or 1D array
    %               statistic to use (see regionprops for list) OR
    %               user-defined data to display
    %
    % Optional key/value inputs:
    %   showDensity     logical [false]
    %       Show additional figure with PDF
    %   rankOrder       logical [false]
    %       Show rank among all ROIs rather than raw value.
    %   scaleCData      logical [true]
    %       Scale CData by setting 0s to just below min value
    %   Image           2D matrix
    %       Image needed for some regionprops stats like MeanIntensity
    %   Bkgd            RGB value [0 0 0]
    %       Background color
    %
    % Output:
    %   stats       vector
    %       Statistic for each ROI
    %   L           2D matrix (X, Y)        
    %       Image with stat value at locations of each ROIs
    %
    % Example:
    %   im = imread('my_image.png');
    %   [regions, rois] = detectMSERFeatures(im);  % detection function
    %   roiColorByStat(rois, 'Area');
    %
    % See also:
    %   REGIONPROPS, LABELMATRIX
    % 
    % History:
    %   07Aug2020 - SSP
    %   23Aug2020 - SSP - Added stat output and image stat option
    %   21Oct2020 - SSP - Added user-defined stat and labelmatrix input
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'ShowDensity', false, @islogical);
    addParameter(ip, 'RankOrder', false, @islogical);
    addParameter(ip, 'ScaleCData', true, @islogical);
    addParameter(ip, 'Bkgd', [0 0 0], @isnumeric);
    addParameter(ip, 'CMap', jet(), @isnumeric);
    addParameter(ip, 'Image', []);
    parse(ip, varargin{:});
    rankOrder = ip.Results.RankOrder;
    scaleCData = ip.Results.ScaleCData;
    im = ip.Results.Image;
    cMap = ip.Results.CMap;

    if ischar(statName)
        if isempty(im)
            stats = regionprops('table', rois, statName);
        else
            stats = regionprops('table', rois, im, statName);
        end
        stats = stats{:, 1};
    else
        stats = statName;
        statName = 'User-Defined';
    end

    if isstruct(rois)
        L = labelmatrix(rois);
    else
        L = rois;
    end

    numROIs = max(max(L));
    [m, n] = size(L);
    L2 = double(L(:));
    if rankOrder
        [~, ind] = sort(stats);
        for i = 1:numROIs
            L2(L2 == i) = find(ind == i);
        end
    else  % raw values
        for i = 1:numROIs
            L2(L2 == i) = stats(i);
        end
    end
    if ~rankOrder && scaleCData
        L2(L2 == 0) = min(stats) - 0.001;
    end
    L2 = reshape(L2, [m, n]);


    figure(); imagesc(L2);
    axis equal tight off;
    colorbar(); colormap([ip.Results.Bkgd; cMap]);
    title(['ROIs by ', statName]);

    if ip.Results.ShowDensity
        [f, xi] = ksdensity(stats);
            figure(); hold on;
        h = plotg(xi, f, [], 'jet'); 
        h.LineWidth = 2;
        title(sprintf('ROI %s density function', statName));
        xlabel(statName);
        figPos(gcf, 0.5, 0.5);
    end