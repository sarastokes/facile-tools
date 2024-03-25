function [patches, rois] = extractPatches(originalImage, originalRois, patchSize, saveFlag, dsetNumber)
    if nargin < 3 || isempty(patchSize)
        patchHeight = 64;
        patchWidth = 96;
    else
        patchHeight = patchSize(1);
        patchWidth = patchSize(2);
    end
    if nargin < 4
        saveFlag = false;
    end
    if nargin < 5 && saveFlag
        error('Provide dataset number');
    end

    % Calculate the number of patches along each dimension
    numPatchesX = floor(size(originalImage, 2) / patchWidth);
    numPatchesY = floor(size(originalImage, 1) / patchHeight);

    % Initialize a cell array to store patches
    patches = cell(numPatchesY, numPatchesX);
    rois = cell(numPatchesY, numPatchesX);

    % Loop through each row and column to extract patches
    for row = 1:numPatchesY
        for col = 1:numPatchesX
            x1 = (col - 1) * patchWidth + 1;
            y1 = (row - 1) * patchHeight + 1;
            x2 = x1 + patchWidth - 1;
            y2 = y1 + patchHeight - 1;

            % Check if the patch is within image boundaries
            if x2 <= size(originalImage, 2) && y2 <= size(originalImage, 1)
                patches{row, col} = imcrop(originalImage, [x1, y1, patchWidth - 1, patchHeight - 1]);
                rois{row,col} = imcrop(originalRois, [x1, y1, patchWidth-1, patchHeight-1]);
            end
        end
    end

    % Display the original image and patches
    figure;
    subplot(numPatchesY + 1, numPatchesX + 1, 1);
    imshow(originalImage);

    for row = 1:numPatchesY
        for col = 1:numPatchesX
            ax = subplot(numPatchesY + 1, numPatchesX + 1, (row - 1) * numPatchesX + col + 1);
            if ~isempty(patches{row, col})
                roiOverlay(patches{row, col}, rois{row,col}, 'Parent', ax);
            else  
                % Display blank for out-of-bound patches
                imshow(zeros(patchHeight, patchWidth, 3));
            end
        end
    end

    if ~saveFlag
        return
    end

    fprintf('Saving %u patches\n', numPatchesX * numPatchesY);

    counter = 0;
    for i = 1:numPatchesY
        for j = 1:numPatchesX
            counter = counter + 1;
            imwrite(patches{i,j}, sprintf('Image%d_Patch%d.tif', dsetNumber, counter));
            imwrite(rois{i,j}, sprintf('Image%d_Label%d.tif', dsetNumber, counter));
        end
    end
