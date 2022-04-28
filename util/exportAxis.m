function newAxes = exportAxis(ax)
	% EXPORTAXIS  
    %
    % Description:
    %   Export a specific axis to new figure window
    %
    % Syntax:
    %   newAxes = exportAxis(ax);
	%
	% Inputs:
    %   ax          Axes handle
    % Output:
    %   newAxes     New axes handle
    %
    % History:
    %   06Jan2017 - SSP - moved from NeuronApp/RenderApp
    %   11Jan2022 - SSP - renamed from exportFigure to be more accurate
	% ---------------------------------------------------------------------

	newAxes = copyobj(ax, figure());
	set(newAxes,...
		'ActivePositionProperty', 'outerposition',...
		'Units', 'normalized',...
		'Position', [0, 0, 1, 1],...
		'OuterPosition', [0, 0, 1, 1]);