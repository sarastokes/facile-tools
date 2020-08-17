function imMidAdj = topbotFilter(im, r, verbose)
    % TOPBOTFILTER
    %
    % Syntax:
    %   im2 = topbotFilter(im, r)
    %
    % Inputs:
    %   im          Image
    %   r           Radius for STREL
    %   verbose     logical     (default = false)
    %               Output pictures of each processing step
    %
    % See also:
    %   STREL, IMTOPHAT, IMBOTHAT, IMADJUST
    % 
    % History:
    %    8Aug2020  - SSP
    %   17Aug2020 - SSP - Added verbose option to reduce default output
    % --------------------------------------------------------------------

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

    % Take the difference and potentially contrast adjust
    imMid = imTop - imBot;
    imMidAdj = imadjust(imTop - imBot);

    if verbose
        figure(); imshow(imMidAdj);
        figPos(gcf, 1.5, 2);
        tightfig(gcf);
    end