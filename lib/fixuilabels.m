function fixuilabels(hFig)
%FIXUILABELS   Change 'text' uicontrol objects' vertical alignment
%   FIXUILABELS traverses through the java objects contained within the
%   current MATLAB figure and adjust the underlying java objects for all
%   the 'text' style uicontrols so that their texts better line up with the
%   adjacent 'edit' style uicontrols at the same height.
%
%   FIXUILABELS(FIG) fixes the uicontrols in the figure with handle FIG.
%
%   ACKNOWLEDGEMENT: This function is based on Yair Altman's findobj
%   (http://www.mathworks.com/matlabcentral/fileexchange/14317)
% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (06-10-2013) original release
% Ensure Java AWT is enabled
error(javachk('awt'));
error(nargchk(0,1,nargin));
% Get figure
if nargin<1
   hFig = getCurrentFigure;
else
   if ~(numel(hFig)==1 && ishghandle(hFig) && strcmp(get(hFig,'type'),'figure'))
      error('FIG does not appear to be a valid figure handle.');
   end
end
drawnow;
try
   % Default container is the current figure's root panel
   container = getRootPanel(hFig);
   
   % Traverse the container hierarchy and adjust the label objects
   traverseContainer(container);
   
catch ME
   % 'Cleaner' error handling - strip the stack info etc.
   err = MException.last;
   err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
   if isempty(strfind(err.message,mfilename))
      err.message = [mfilename ': ' err.message];
   end
   rethrow(err);
end
end
%% Traverse the container hierarchy and adjust all LabelPeer objects
function traverseContainer(jcontainer)
% Record the data for this node
%disp(char(jcontainer.toString))
if isa(jcontainer,'com.mathworks.hg.peer.LabelPeer$1')
   jcontainer.setVerticalAlignment(0); % "middle" aligned
end
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.38 $  $Date: 2013/05/15 21:58:17 $
lastChildComponent = java.lang.Object;
child = 0;
try % try to terminate recursion when jcontainer does not have ComponentCount property
   while (child < jcontainer.getComponentCount)
      childComponent = jcontainer.getComponent(child);
      % Looping over menus sometimes causes jcontainer to get mixed up (probably a JITC bug), so identify & fix
      if isequal(childComponent,lastChildComponent)
         child = child + 1;
         childComponent = jcontainer.getComponent(child);
      end
      lastChildComponent = childComponent;
      traverseContainer(childComponent) % returns true if LabelPeer object
      child = child + 1;
   end
catch
end
end
%% Get current figure (even if its 'HandleVisibility' property is 'off')
function curFig = getCurrentFigure
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.38 $  $Date: 2013/05/15 21:58:17 $
oldShowHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');  % minor fix per Johnny Smith
curFig = gcf;
set(0,'ShowHiddenHandles',oldShowHidden);
end
%% Get Java reference to top-level (root) panel - actually, a reference to the java figure
function jRootPane = getRootPanel(hFig)
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.38 $  $Date: 2013/05/15 21:58:17 $
try
   jRootPane = hFig;
   figName = get(hFig,'name');
   if strcmpi(get(hFig,'number'),'on')
      figName = regexprep(['Figure ' num2str(hFig) ': ' figName],': $','');
   end
   mde = com.mathworks.mde.desk.MLDesktop.getInstance;
   jFigPanel = mde.getClient(figName);
   jRootPane = jFigPanel;
   jRootPane = jFigPanel.getRootPane;
catch
   try
      warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');  % R2008b compatibility
      jFrame = get(hFig,'JavaFrame');
      jFigPanel = get(jFrame,'FigurePanelContainer');
      jRootPane = jFigPanel;
      jRootPane = jFigPanel.getComponent(0).getRootPane;
   catch
      % Never mind
   end
end
try
   % If invalid RootPane - try another method...
   warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');  % R2008b compatibility
   jFrame = get(hFig,'JavaFrame');
   jAxisComponent = get(jFrame,'AxisComponent');
   jRootPane = jAxisComponent.getParent.getParent.getRootPane;
catch
   % Never mind
end
try
   % If invalid RootPane, retry up to N times
   tries = 10;
   while isempty(jRootPane) && tries>0  % might happen if figure is still undergoing rendering...
      drawnow; pause(0.001);
      tries = tries - 1;
      jRootPane = jFigPanel.getComponent(0).getRootPane;
   end
   
   % If still invalid, use FigurePanelContainer which is good enough in 99% of cases... (menu/tool bars won't be accessible, though)
   if isempty(jRootPane)
      jRootPane = jFigPanel;
   end
   
   % Try to get the ancestor FigureFrame
   jRootPane = jRootPane.getTopLevelAncestor;
catch
   % Never mind - FigurePanelContainer is good enough in 99% of cases... (menu/tool bars won't be accessible, though)
end
end
