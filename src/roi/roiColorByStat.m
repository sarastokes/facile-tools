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
    %   rois        struct
    %               Connected components from a detection function
    %   statName    char
    %               statistic to use (see regionprops for list)
    %
    % Optional key/value inputs:
    %   rankOrder   logical [false]
    %       Show rank among all ROIs rather than raw value.
    %   scaleCData  logical [true]
    %       Scale CData by setting 0s to just below min value
    %   Image       2D matrix
    %       Image needed for some regionprops stats like MeanIntensity
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
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'RankOrder', false, @islogical);
    addParameter(ip, 'ScaleCData', true, @islogical);
    addParameter(ip, 'Image', []);
    parse(ip, varargin{:});
    rankOrder = ip.Results.RankOrder;
    scaleCData = ip.Results.ScaleCData;
    im = ip.Results.Image;

    
    if isempty(im)
        stats = regionprops('table', rois, statName);
    else
        stats = regionprops('table', rois, im, statName);
    end
    stats = stats{:, 1};
    L = labelmatrix(rois);

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
    colorbar(); colormap([0 0 0; jet]);
    title(['ROIs by ', statName]);

    [f, xi] = ksdensity(stats);
    figure(); hold on;
    h = plotg(xi, f, [], 'jet'); 
    h.LineWidth = 2;
    title(sprintf('ROI %s density function', statName));
    xlabel(statName);
    figPos(gcf, 0.5, 0.5);