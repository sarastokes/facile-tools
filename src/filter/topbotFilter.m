function imMidAdj = topbotFilter(im, r)
    % TOPBOTFILTER
    %
    % Syntax:
    %   im2 = topbotFilter(im, r)
    %
    % Inputs:
    %   im          Image
    %   r           Radius for STREL
    %
    % See also:
    %   STREL, IMTOPHAT, IMBOTHAT, IMADJUST
    % 
    % History:
    %   8Aug2020 - SSP
    % --------------------------------------------------------------------

    SE = strel('disk', r);
    imTop = imtophat(im, SE);
    imBot = imbothat(im, SE);

    figure();
    imshowpair(imTop, imBot, 'montage');
    title(sprintf('strel = %u', r));
    figPos(gcf, 1.5, 1.5);
    tightfig(gcf);

    % Take the difference and potentially contrast adjust
    imMid = imTop - imBot;
    imMidAdj = imadjust(imTop - imBot);

    figure(); 
    imshowpair(imMid, imMidAdj, 'montage');
    title(sprintf('strel = %u', r));
    figPos(gcf, 1.5, 1.5);
    tightfig(gcf);

    ax = axes('Parent', figure()); 
    imagesc(imMid); 
    colormap('pink');
    title(sprintf('strel = %u', r));
    figPos(gcf, 1, 1.5);
    axis equal tight off
    tightfig(gcf);
    ax.Position(4) = ax.Position(4) - (0.05 * ax.Position(4));