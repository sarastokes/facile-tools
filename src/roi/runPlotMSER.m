function [regions, rois] = runPlotMSER(im, varargin)
    % RUNPLOTMSER
    %
    % Description:
    %   Wrapper from detectMSERFeatures that includes a plot and cmd output
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
    % Note:
    %   Plotting is most time consuming part so skip it whenever possible
    %
    % See also:
    %   DETECTMSERFEATURES
    % 
    % History:
    %    7Aug2020 - SSP
    %   26Aug2020 - SSP - Added no plot option (basically original fcn)
    %   26Oct2020 - SSP - figure shows "plotting..." during wait
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    ip.KeepUnmatched = true;
    ip.CaseSensitive = false;
    addParameter(ip, 'Plot', true, @islogical);
    parse(ip, varargin{:});
    

    [regions, rois] = detectMSERFeatures(im, ip.Unmatched);
    fprintf('Identified %u regions\n', rois.NumObjects);

    if ip.Results.Plot
        figure(); imshow(im); hold on;
        title('Plotting...'); drawnow;
        plot(regions, 'showPixelList', true, 'showEllipses', false);
        title(sprintf('MSER Features (%u)', rois.NumObjects));
    end
    
