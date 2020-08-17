function [regions, rois] = runPlotMSER(im, varargin)
    % RUNPLOTMSER
    %
    % Description:
    %   Wrapper from detectMSERFeatures that includes a plot
    %
    % Syntax:
    %   [regions, rois] = runPlotMSER(im, varargin);
    %
    % Inputs:
    %   Same as detectMSERFeatures.
    %
    % Outputs:
    %   Same as detectMSERFeatures.
    %
    % See also:
    %   DETECTMSERFEATURES
    % 
    % History:
    %   7Aug2020 - SSP
    % --------------------------------------------------------------------

    [regions, rois] = detectMSERFeatures(im, varargin{:});
    fprintf('Identified %u regions\n', rois.NumObjects);

    figure(); imshow(im); hold on;
    plot(regions, 'showPixelList', true, 'showEllipses', false);
    tightfig(gcf);
    
