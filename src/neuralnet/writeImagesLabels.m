function writeImagesLabels(images, labels, dataPath, dsetNo)

    imageDir = fullfile(dataPath, "images");
    labelDir = fullfile(dataPath, "labels");

    if ~exist(dataPath, "dir")
        mkdir(dataPath); mkdir(imageDir); mkdir(labelDir);
    end

    numImages = size(images, 3);
    fprintf('Writing %u images\n', numImages);

    for i = 1:numImages
        imwrite(squeeze(images(:,:,i)),... 
            fullfile(imageDir, sprintf("Dataset%u_Image%u.tif", dsetNo, i)));
        imwrite(squeeze(labels(:,:,i)),... 
            fullfile(labelDir, sprintf("Dataset%u_Image%u.tif", dsetNo, i)));
    end




