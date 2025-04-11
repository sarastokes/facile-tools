function convertAviDual(folderName, epochIDs)

    arguments
        folderName      string      {mustBeFolder(folderName)}
        epochIDs        double      {mustBeInteger(epochIDs)}
    end

    % Get the data folders for the reflectance and visible channels
    refFiles = getTargetFiles(fullfile(folderName, "Ref"));
    visFiles = getTargetFiles(fullfile(folderName, "Vis"));

    progressbar();
    for i = 1:numel(epochIDs)
        if ~isempty(find(contains(refFiles, sprintf("%04.0fO.avi", epochIDs(i))))) %#ok<EFIND>
            warning('Ref file already converted for ID %u, skipping...',...
                epochIDs(i))
            continue
        end

        % Find the specific files
        [iRefFile, iNewRef] = findAndValidateFile(refFiles, epochIDs(i));
        [iVisFile, iNewVis] = findAndValidateFile(visFiles, epochIDs(i));
        if iNewRef == ""
            continue
        end


        % Import the old videos
        vRefIn = VideoReader(fullfile(folderName, "Ref", iRefFile));
        nRefFrames = vRefIn.NumFrames;
        fps = vRefIn.FrameRate;

        vVisIn = VideoReader(fullfile(folderName, "Vis", iVisFile));
        nVisFrames = vVisIn.NumFrames;

        % Correct mismatched frames that mess up strip registration
        if nRefFrames ~= nVisFrames
            warning('Videos do not have same number of frames\n\t%u vs. %u\n',...
                nRefFrames, nVisFrames);
        end
        nFrames = min([nRefFrames, nVisFrames]);

        % Write the new reflectance video
        vRefOut = VideoWriter(fullfile(folderName, "Ref", iNewRef), 'Grayscale AVI');
        vRefOut.FrameRate = fps;
        open(vRefOut);
        for j = 1:nFrames
            iFrame = read(vRefIn, j);
            writeVideo(vRefOut, iFrame);
        end
        close(vRefOut);

        % Write the new fluorescence video
        vVisOut = VideoWriter(fullfile(folderName, "Vis", iNewVis), 'Grayscale AVI');
        vVisOut.FrameRate = fps;
        open(vVisOut);
        for j = 1:nFrames
            iFrame = read(vVisIn, j);
            writeVideo(vVisOut, iFrame);
        end
        close(vVisOut);

        % Report out status
        fprintf('%04.0f - %s\n', epochIDs(i), iRefFile);
        progressbar(i/numel(epochIDs));
    end
end

function fileNames = getTargetFiles(folderName)
    allFiles = getFolderFiles(folderName);
    % Get just the AVI files
    aviFiles = allFiles(endsWith(allFiles, ".avi"));
    % Remove registered videos
    aviFiles = aviFiles(~contains(aviFiles, ["frame", "strip"]));
    % Remove already converted videos
    fileNames = aviFiles(~endsWith(aviFiles, "O.avi"));
end

function [iFile, newFile] = findAndValidateFile(rawFiles, epochID)
    % Find the specific file
    iFile = rawFiles(contains(rawFiles, sprintf("%04.0f", epochID)));

    % Catch unexpected results
    if isempty(iFile)
        warning('No file found for ID %u (%s), skipping...',...
            epochID, sprintf("%04.0f", epochID));
        newFile = "";
    elseif numel(iFile) > 1
        % Was the match within the monkey ID or date?
        iFile = iFile(contains(iFile, sprintf("_%04.0f", epochID)));
        if numel(iFile) > 1
            warning('Found %u files for ID %u, skipping...',...
                numel(iFile), epochID);
        end
        newFile = "";
    else
        % Append a O to the end of the new video
        newFile = strrep(iFile, ".avi", "O.avi");
    end

end