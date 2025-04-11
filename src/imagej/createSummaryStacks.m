function createSummaryStacks(experimentDir, epochIDs, filePrefix, saveFlag)
% CREATESUMMARYSTACKS
%
% Inputs:
%   experimentDir       string
%       Path to the experiment directory
%   epochIDs            double
%       Vector of epochIDs to use to create the stack
%   filePrefix          string
%       Prefix for the summary stack files (e.g., 838_ODR_20241108)
% Optional inputs:
%   saveFlag            logical (default = false)
%       Whether to save the summary stacks
%
% See also:
%   MakeSummaryStacks.m
% -------------------------------------------------------------------------

    arguments
        experimentDir       string {mustBeFolder}
        epochIDs            double {mustBeInteger}
        filePrefix          string
        saveFlag            logical = false
    end

    epochIDs = sort(epochIDs);
    summaryStackParameters = struct(...
        "experimentDir", experimentDir,...
        "epochIDs", epochIDs,...
        "filePrefix", filePrefix,...
        "saveFlag", saveFlag);

    assignin('base', 'summaryStackParameters', summaryStackParameters);
    evalin('base', 'run(''MakeSummaryStacks.m'')');

% MAKESUMMARYSTACKS2
%
% Requirements:
%   experimentDir (can be pulled from "p")
%   epochIDs
%   filePrefix  (e.g., 838_ODR_20241108)

