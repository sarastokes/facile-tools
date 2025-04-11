function fileNames = getFolderFiles(folderName)

    arguments
        folderName    (1,1)  {mustBeFolder}
    end


    d = dir(folderName);
    fileNames = arrayfun(@(x) string(x.name), d, 'UniformOutput', true);
    % Remove "." and ".."
    fileNames = fileNames(3:end);