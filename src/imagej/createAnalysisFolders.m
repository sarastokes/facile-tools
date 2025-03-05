function createAnalysisFolders(experimentDir)

    arguments
        experimentDir   (1,1)   string {mustBeFolder}
    end

    if ~isfolder(fullfile(experimentDir, "Analysis"))
        mkdir(fullfile(experimentDir, "Analysis"));
    end
    subFolders = ["Videos", "Snapshots", "Plots"];
    for i = 1:numel(subfolders)
        if ~isfolder(experimentDir, "Analysis", subFolders(i))
            mkdir(experimentDir, "Analysis", subFolders(i));
        end
    end