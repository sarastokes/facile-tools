function previewAugmentation(dsAug, numTiles, resetAfter)

    if nargin < 3
        resetAfter = true;
    end

    numImages = numTiles^2;

    dsAug.reset();

    figure();
    for i = 1:numel(numImages)
        subplot(numTiles, numTiles, i);
        imshow(dsAug.Images{i});
    end


    if resetAfter
        dsAug.reset();
    end