function expandLabels(roiMask, roiImage, outputFolder)
    % This is where the labels go
    labelFolder = fullfile(outputFolder, 'PixelLabelData');
    if ~exist(labelFolder, 'dir')
        mkdir(labelFolder);
    end
    % This is where the images go
    imageFolder = fullfile(outputFolder, 'ImageData');
    if ~exist(imageFolder, 'dir')
        mkdir(imageFolder);
    end

    numROIs = numel(unique(roiMask(:))) - 1;



    for i = 1:numROIs
        iMask = roiMask==i;
        iMask = uint8(iMask);
        imwrite(iMask, fullfile(outputFolder, sprintf('label_%03d.png', i)));
    end