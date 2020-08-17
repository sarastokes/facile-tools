function h = roiOverlay(im, labelMatrix)
    % ROIOVERLAY
    %
    % Syntax:
    %    h = roiOverlay(im, labelMatrix)
    %
    % Inputs:
    %   im              double (will be converted if not)
    %       Image to overlay rois
    %   labelMatrix     2D matrix
    %       Matrix of roi locations from labelmatrix function
    %
    % Outputs:
    %   h               matlab.graphics.primitive.Image
    %       Handle to imagesc image containing rois
    %
    % See also:
    %   LABELMATRIX
    %
    % History:
    %   10Aug2020 - SSP
    % --------------------------------------------------------------------

    im = im2double(im);

    % Binarize roi image
    labelMatrix(labelMatrix > 0) = 1;

    figure(); imshow(im); hold on;
    map = colormap('gray');
    map = [map; 0 1 0];
    colormap(map);

    h = imagesc(labelMatrix);
    h.AlphaData = 0.5 * (labelMatrix > 0);
    