function [ax, h2, h3] = prepResponseVideo(coneImage, titleStr)
    % PREPRESPONSEVIDEO
    %
    % Syntax:
    %   [ax, h2, h3] = prepResponseVideo(coneImage,titleStr)
    %
    % History:
    %   21Jun2022 - SSP
    % ---------------------------------------------------------------------
        
    %  Create the figure
    ax = axes('Parent', figure());
    % Add the cone image
    h1 = imshow(coneImage);
    hold on;
    % Add the GCaMP6 responses
    h2 = imagesc(0.5+zeros(360, 242));
    % Position over right side
    h2.XData = h2.XData + (h1.XData(end) - h2.XData(end));
    
    % Add the stimulus 
    h3 = imagesc(0.5+zeros(256, 256));
    % Position over target cross
    h3.YData = 179 - (256/2) + h3.YData;
    h3.XData = h3.XData - 2;
    % Make semi-transparent
    h3.AlphaData = 0.6;
    
    if nargin > 1
        title(titleStr, 'FontSize', 14, 'FontName', 'Lato');
    end
    tightfig(gcf);
    ax.Position(1) = 0.01;
    ax.Position(3) = 0.98;
    drawnow;
