function im2 = estimateSystemBlur(im, plotFlag)
    % ESTIMATESYSTEMBLUR
    %
    % Syntax:
    %   im2 = estimateSystemBlur(im);
    %
    % Inputs:
    %   im      matrix
    %       Image to analyze
    % Optional:
    %   plotFlag   logical (default = false)
    %       Plot the result
    %
    % Outputs:
    %   im2     matrix
    %       Image with vertical blur from system added
    % 
    % Notes:
    %   SD measured from impulse function stimuli on 20211214
    %   For calculations, see: x20211214_horiz_vert_impulse_fcn.mlx
    %
    % History:
    %   15Dec2021 - SSP
    % ---------------------------------------------------------------------
    if nargin < 2
        plotFlag = false;
    end
    im = im2double(im);
    maxVal = max(im(:));

    vFilt = normpdf(-15:1:15, 0, 1.6593);
    vFilt = vFilt/max(vFilt);

    im2 = conv(im(:), vFilt, 'same');
    im2 = reshape(im2, size(im));

    im2 = maxVal * im2/max(abs(im2(:)));

    figure(); hold on;
    imagesc(im2);
    colormap('gray');
    axis equal tight off;
    caxis(gca, [0 1]);
