function convertAvi(folderName, epochIDs)
% CONVERTAVI
%
% Description:
%   Converts Primate 1P system videos into a format readable by Qiang's
%   ImageReg software. Videos that have already been registered or
%   converted will be skipped. The new videos will have the same file name
%   as before, but with an "O" at the end.
%
% Syntax:
%   convertAvi(folderName, epochIDs)
%
% Inputs:
%   folderName          string/char
%       The folder containing the videos you want to convert
%   epochIDs            array of integers
%       The video numbers you want to convert
%
% Examples:
%   % Convert videos 1-10 in the "Ref" folder
%   convertAvi('C:/Users/yourname/MC00838_20221122/Ref', 1:10)

%   Sara Patterson, 2023 (facile-tools)
% -------------------------------------------------------------------------

    arguments
        folderName      string      {mustBeFolder(folderName)}
        epochIDs        double      {mustBeInteger(epochIDs)}
    end

    allFiles = getFolderFiles(folderName);
    aviFiles = allFiles(endsWith(allFiles, ".avi"));
    % Remove registered videos
    aviFiles = aviFiles(~contains(aviFiles, ["frame", "strip"]));
    % Remove already converted videos
    rawFiles = aviFiles(~endsWith(aviFiles, "O.avi"));

    for i = 1:numel(epochIDs)

        if ~isempty(find(contains(aviFiles, sprintf("%04.0fO.avi", epochIDs(i))))) %#ok<EFIND>
            warning('File already converted for ID %u, skipping...',...
                epochIDs(i))
            continue
        end

        % Find the specific file
        iFile = rawFiles(contains(rawFiles, sprintf("%04.0f", epochIDs(i))));

        % Catch unexpected results
        if isempty(iFile)
            warning('No file found for ID %u (%s), skipping...',...
                epochIDs(i), sprintf("%04.0f", epochIDs(i)));
            continue
        elseif numel(iFile) > 1
            % Was the match within the monkey ID or date?
            iFile = iFile(contains(iFile, sprintf("_%04.0f", epochIDs(i))));
            if numel(iFile) > 1
                warning('Found %u files for ID %u, skipping...',...
                    numel(iFile), epochIDs(i));
                continue
            end
        end

        % Append a O to the end of the new video
        newFile = strrep(iFile, ".avi", "O.avi");

        % Import the old video
        vIn = VideoReader(fullfile(folderName, iFile)); %#ok<*TNMLP>
        frames = vIn.NumFrames;
        fps = vIn.FrameRate;

        % Write to a new video
        vOut = VideoWriter(fullfile(folderName, newFile), 'Grayscale AVI');
        vOut.FrameRate = fps;
        open(vOut);

        for j = 1:frames
            iFrame = read(vIn, j);
            writeVideo(vOut, iFrame);
        end

        close(vOut);

        fprintf('%04.0f - %s\n', epochIDs(i), iFile);
    end
end