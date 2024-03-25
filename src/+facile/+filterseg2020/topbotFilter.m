function [imFiltered, imTop, imBot] = topbotFilter(im, r, verbose)
    % TOPBOTFILTER
    %
    % Syntax:
    %   [imFiltered, imTop, imBot] = topbotFilter(im, r)
    %
    % Inputs:
    %   im          Image
    %   r           Radius for STREL
    %   verbose     logical     (default = false)
    %               Output pictures of each processing step
    % Outputs:
    %   imFiltered  2D matrix
    %       Image filtered and contrast adjusted
    %   imTop       2D matrix
    %       Image bottom-hat filtered
    %   imBot       2D matrix
    %       Image top-hat filtered
    %
    % See also:
    %   STREL, IMTOPHAT, IMBOTHAT, IMADJUST
    % 
    % History:
    %    8Aug2020 - SSP
    %   17Aug2020 - SSP - Added verbose option to reduce default output
    %   24Aug2020 - SSP - Added outputs to access intermediate images
    % ---------------------------------------------------------------------

    if nargin < 3
        verbose = false;
    end

    SE = strel('disk', r);
    imTop = imtophat(im, SE);
    imBot = imbothat(im, SE);

    if verbose
        figure();
        imshowpair(imTop, imBot, 'montage');
        figPos(gcf, 1.5, 1.5);
        tightfig(gcf);
    end

    % Take the difference and contrast adjust
    imFiltered = imadjust(imTop - imBot);

    if verbose
        figure(); imshow(imFiltered);
        figPos(gcf, 1.5, 2);
        tightfig(gcf);
    end