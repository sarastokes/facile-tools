function [patches, rois] = extractPatches3(image, labels, dsetNo, patchSize, saveDir, varargin)
%EXTRACTPATCHES3
%
% Syntax:
%   [patches, rois] = extractPatches3(image, labels, dsetNo, patchSize,... 
%       saveDir, 'NumReps', 2, 'Padding', 0, 'Plot', false)
%
% -------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'NumReps', 2, @isnumeric);
    addParameter(ip, 'Padding', 0, @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    padding = ip.Results.Padding;
    plotFlag = ip.Results.Plot;
    numReps = ip.Results.NumReps;

    % Make sure subfolders are present
    if ~exist(fullfile(saveDir, 'images'), 'dir')
        mkdir(fullfile(saveDir, 'images'));
    end
    if ~exist(fullfile(saveDir, 'labels'), 'dir')
        mkdir(fullfile(saveDir, 'labels'));
    end
    imagePath = fullfile(saveDir, 'images',...
        ['Image', num2str(dsetNo), '_Patch%d.tif']);
    labelPath = fullfile(saveDir, 'labels',...
        ['Image', num2str(dsetNo), '_Patch%d.tif']);

    % Extract the image and labels, cutting edges if needed
    if padding ~= 0
        image = image(padding:end-padding+1, padding:end-padding+1);
        labels = labels(padding:end-padding+1, padding:end-padding+1);
    end

    % Get the bounding boxes and split into cells for cellfun
    S = regionprops(labels, 'BoundingBox');
    roiBoxes = vertcat(S.BoundingBox);
    roiBoxes = num2cell(roiBoxes, 2);

    % Calculate the number of patches along each dimension
    patchHeight = patchSize(1);
    patchWidth = patchSize(2);
    numPatchesX = floor(size(image, 2) / patchWidth);
    numPatchesY = floor(size(image, 1) / patchHeight);

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

            patchBox = [x1, y1, patchWidth, patchHeight];
            validMasks = find(cellfun(@(x) isFullyContained(x, patchBox, 1), roiBoxes));
            validLabels = reshape(ismember(labels(:), validMasks), size(labels));

            validLabels = 255 * uint8(validLabels);

            % Check if the patch is within image boundaries
            if x2 <= size(image, 2) && y2 <= size(image, 1)
                patches{row, col} = imcrop(image,...
                    [x1, y1, patchWidth - 1, patchHeight - 1]);
                rois{row,col} = imcrop(validLabels,...
                    [x1, y1, patchWidth-1, patchHeight-1]);
            end
        end
    end

    if plotFlag
        displayPatches(patches, rois, image, numPatchesX, numPatchesY);
    end


    % Save the patches and augment as requested
    counter = 0;

    for i = 1:numPatchesY
        for j = 1:numPatchesX
            for k = 1:4
                if k == 1
                    iPatch = patches{i,j};
                    iRoi = rois{i,j};
                elseif k == 2
                    [iPatch, iRoi] = hFlip(iPatch, iRoi);
                elseif k == 3
                    [iPatch, iRoi] = vFlip(iPatch, iRoi);
                elseif k == 4
                    [iPatch, iRoi] = bFlip(iPatch, iRoi);
                end

                counter = counter + 1;
                writeImage(iPatch, imagePath, counter);
                writeLabel(iRoi, labelPath, counter);

                for l = 1:numReps
                    counter = counter + 1;
                    [newPatch, newRoi] = randRotation(iPatch, iRoi, [10 45]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);

                    counter = counter + 1;
                    [newPatch, newRoi] = randRotation(iPatch, iRoi, -[45 10]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);
                end

                for l = 1:numReps
                    counter = counter + 1;
                    [newPatch, newRoi] = randHShear(iPatch, iRoi, [5 15]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);

                    counter = counter + 1;
                    [newPatch, newRoi] = randHShear(iPatch, iRoi, -[15 5]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);


                    counter = counter + 1;
                    [newPatch, newRoi] = randVShear(iPatch, iRoi, [5 15]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);

                    counter = counter + 1;
                    [newPatch, newRoi] = randVShear(iPatch, iRoi, -[15 5]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);
                end

                for l = 1:numReps
                    counter = counter + 1;
                    [newPatch, newRoi] = randRotation(iPatch, iRoi, [20 45]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);

                    counter = counter + 1;
                    [newPatch, newRoi] = randRotation(iPatch, iRoi, -[45 20]);
                    writeImage(newPatch, imagePath, counter);
                    writeLabel(newRoi, labelPath, counter);
                end
            end

            if i == 1 && j == 1
                fprintf('Saving %u versions of each patch\n', counter);
            end
        end
    end

    fprintf('Saved %d patches from %d sections\n', counter, numPatchesX*numPatchesY);
end

function writeImage(image, imagePath, counter)
    imwrite(image, strrep(imagePath, "%d", num2str(counter)));
end
function writeLabel(label, labelPath, counter)
    imwrite(label, strrep(labelPath, "%d", num2str(counter)));
end

function displayPatches(patches, rois, image, numPatchesX, numPatchesY)
    % Display the original image and patches
    figure();
    subplot(numPatchesY + 1, numPatchesX + 1, 1);
    imshow(image);

    for row = 1:numPatchesY
        for col = 1:numPatchesX
            ax = subplot(numPatchesY + 1, numPatchesX + 1,...
                (row - 1) * numPatchesX + col + 1);
            if ~isempty(patches{row, col})
                roiOverlay(patches{row, col}, rois{row,col}, 'Parent', ax);
            else
                % Display blank for out-of-bound patches
                imshow(zeros(patchHeight, patchWidth, 3));
            end
        end
    end
end


function [newImage, newLabels] = randRotation(image, labels, rotRange)

    tform = randomAffine2d('Rotation', rotRange);
    outputView = affineOutputView(size(image), tform);
    newImage = imwarp(image, tform, 'OutputView', outputView);
    newLabels = imwarp(labels, tform, 'OutputView', outputView);
end

function [newImage, newLabels] = randHShear(image, labels, shearRange)
    tform = randomAffine2d('XShear', shearRange);
    outputView = affineOutputView(size(image), tform);
    newImage = imwarp(image, tform, 'OutputView', outputView);
    newLabels = imwarp(labels, tform, 'OutputView', outputView);
end

function [newImage, newLabels] = randVShear(image, labels, shearRange)
    tform = randomAffine2d('YShear', shearRange);
    outputView = affineOutputView(size(image), tform);
    newImage = imwarp(image, tform, 'OutputView', outputView);
    newLabels = imwarp(labels, tform, 'OutputView', outputView);
end

function [newImage, newLabels] = hFlip(image, labels)
    newImage = fliplr(image);
    newLabels = fliplr(labels);
end

function [newImage, newLabels] = vFlip(image, labels)
    newImage = flipud(image);
    newLabels = flipud(labels);
end

function [newImage, newLabels] = bFlip(image, labels)
    newImage = fliplr(flipud(image));
    newLabels = fliplr(flipud(labels));
end

