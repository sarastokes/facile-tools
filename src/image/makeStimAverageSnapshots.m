function makeStimAverageSnapshots(dataset, saveFolder)
% MAKESTIMAVERAGESNAPSHOTS

    if nargin < 2
        snapshotFolder = fullfile(dataset.experimentDir, 'Analysis',...
            'Snapshots', 'Stimuli');
        if ~isfolder(snapshotFolder)
            mkdir(snapshotFolder);
        end
    end

    stimuli = dataset.stim.Stimulus;
    fprintf("Stimulus files created:\n")

    for i = 1:numel(stimuli)
        epochIDs = dataset.stim2epochs(stimuli(i));
        imStack = im2double(dataset.getEpochStacks(epochIDs));

        stimFile = sprintf("%s_%u_%s.png", dataset.getLabel(), ...
            numel(epochIDs), char(stimuli(i)));

        % STD image
        imStd = mean(std(imStack, [], 3), 4);
        imStd = im2uint8(imadjust(imStd));
        imwrite(imStd, fullfile(snapshotFolder, "STD_" + stimFile));

        % SUM image
        imSum = sum(sum(im2double(imStack), 3), 4);
        imSum = uint8(255 * imSum/max(imSum(:)));
        imwrite(imSum, fullfile(snapshotFolder, "SUM_" + stimFile));

        fprintf("\t%s\n", stimFile);
    end

