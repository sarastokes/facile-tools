function convertAvi(folderName, epochIDs)
% CONVERTAVI
% 
% Syntax:
%   convertAvi(folderName, epochIDs)
% -------------------------------------------------------------------------

    arguments
        folderName      string      {mustBeFolder(folderName)}    
        epochIDs        double      {mustBeInteger(epochIDs)} 
    end

    allFiles = deblank(string(ls(folderName)));
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
            warning('No file found for ID %u, skipping...',... 
                epochIDs(i));
            return
        elseif numel(iFile) > 1
            warning('Found %u files for ID %u, skipping...',... 
                numel(iFile), epochIDs(i));
            return
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