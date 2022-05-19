function h = addZeroBar(ax)
     % ADDZEROBAR
     %
     % Description:
     %  Adds line at 0 if trace goes below 0, ensure xy limits don't change
     %
     % Syntax:
     %  h = addZeroBar(ax)
     %
     % Note:
     %  Run after adding plot components if you want axis auto
     %
     % See also:
     %  SETXLIMITSANDTICKS, ADDZEROBARIFNEEDED
     %
     % History:
     %  12May2022 - SSP
     % --------------------------------------------------------------------
     
     if nargin == 0
         ax = gca;
     end

     delete(findall(ax, 'Tag', 'ZeroBar')); 
     xLimits = ax.XLim;
     yLimits = ax.YLim;
     h = plot(ax.XLim, [0 0], 'Tag', 'ZeroBar',...
         'Color', [0.15 0.15 0.15], 'LineWidth', 0.2);
     h.Annotation.LegendInformation.IconDisplayStyle = 'off';
     xlim(ax, xLimits);
     ylim(ax, yLimits);
