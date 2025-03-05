function dataset = assignUIDsToROIs(dataset, startLetter)
% ASSIGNUIDSTOROIS
%
% Syntax:
%   assignUIDsToROIs(dataset, startLetter)
%
% Inputs:
%   dataset: ao.core.Dataset subclass
%   startLetter: A single character to start the UID assignment
%
% Example:
%   assignUIDsToROIs(dataset, 'A')
%
% History:
%   02Mar2024 - SSP
% --------------------------------------------------------------------------

    % Create a separate variable to avoid corrupting main table
    roiUIDs = dataset.roiUIDs;

    startLetter = convertStringsToChars(startLetter);
    startLetter = upper(startLetter);
    assert(isscalar(startLetter), 'startLetter must be a single character');

    idx = find(roiUIDs.UID == "");
    fprintf('Found %d ROIs without UID\n', numel(idx));

    letters = 'A':'Z';
    letterArray = repmat(startLetter, [26*26, 3]);
    letterArray(:, 3) = repmat(letters', [26 1]);
    letterArray(:, 2) = repelem(letters, 26);

    letterArray = string(letterArray);
    N = numel(letterArray);  % 26 * 26

    % Make sure there aren't any duplicates
    letterArray = setdiff(letterArray, roiUIDs.UID);
    if numel(letterArray) < N
        fprintf('Found %d existing UIDs starting with %s - skipping them\n',...
            N - numel(letterArray), startLetter);
    end

    % Assign new UIDs from letterArray to the blank UIDs
    roiUIDs.UID(idx) = letterArray(1:numel(idx));

    % Assign back to the main table
    dataset.setRoiUIDs(roiUIDs);
