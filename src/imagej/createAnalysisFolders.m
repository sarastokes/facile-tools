function createAnalysisFolders(experimentDir)

    arguments
        experimentDir   (1,1)   string {mustBeFolder}
    end

    if ~isfolder(fullfile(experimentDir, "Analysis"))
        mkdir(fullfile(experimentDir, "Analysis"));
    end
    subFolders = ["Videos", "Snapshots", "Plots"];
    for i = 1:numel(subFolders)
        if ~isfolder(fullfile(experimentDir, "Analysis", subFolders(i)))
            mkdir(fullfile(experimentDir, "Analysis", subFolders(i)));
        end
    end