function h = addZeroBarIfNeeded(ax)
     % ADDZEROBARIFNEEDED
     %
     % Description:
     %  Adds line at 0 if trace goes below 0, ensure xy limits don't change
     %
     % Syntax:
     %  h = addZeroBarIfNeeded(ax)
     %
     % See also:
     %  SETXLIMITSANDTICKS
     %
     % History:
     %  30Mar2022 - SSP
     % --------------------------------------------------------------------
     
     if ax.YLim(1) < 0
         delete(findall(ax, 'Tag', 'ZeroBar')); 
         xLimits = ax.XLim;
         yLimits = ax.YLim;
         h = plot(ax.XLim, [0 0], 'Tag', 'ZeroBar',...
             'Color', [0.15 0.15 0.15], 'LineWidth', 0.2);
         h.Annotation.LegendInformation.IconDisplayStyle = 'off';
         xlim(ax, xLimits);
         ylim(ax, yLimits);
     end