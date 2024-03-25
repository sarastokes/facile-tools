function [patches, rois] = extractPatches2(image, labels, dsetNo, patchSize, varargin)
% EXTRACTPATCHES2 Extract patches from a dataset
%
% Inputs:
%   dset - a dataset object
%   dsetNo - the dataset number
%   patchSize - a 2-element vector specifying the patch size [h, w]
%
%
% History:
%   28Aug2023 - SSP
%   30Aug2023 - SSP - added blanks
% -----------------------------------------------------------------------

    patchHeight = patchSize(1);
    patchWidth = patchSize(2);

    ip = inputParser();
    ip.CaseSensitive = true;
    addParameter(ip, 'Padding', 0, @isnumeric);
    addParameter(ip, 'HFlip', true, @islogical);
    addParameter(ip, 'VFlip', true, @islogical);
    addParameter(ip, 'BFlip', true, @islogical);
    addParameter(ip, 'ARot', true, @islogical);
    addParameter(ip, 'HVShear', true, @islogical);
    addParameter(ip, 'Resize', false, @islogical);
    addParameter(ip, 'Blank', false, @islogical);
    addParameter(ip, 'SaveDir', cd, @istext);
    parse(ip, varargin{:});

    padding = ip.Results.Padding;
    hFlip = ip.Results.HFlip;
    vFlip = ip.Results.VFlip;
    bFlip = ip.Results.BFlip;
    hvShear = ip.Results.HVShear;
    aRot = ip.Results.ARot;
    addBlank = ip.Results.Blank;
    reSize = ip.Results.Resize;

    saveDir = ip.Results.SaveDir;

    % Make sure subfolders are present
    if ~exist(fullfile(saveDir, 'images'), 'dir')
        mkdir(fullfile(saveDir, 'images'));
    end
    if ~exist(fullfile(saveDir, 'labels'), 'dir')
        mkdir(fullfile(saveDir, 'labels'));
    end

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


    % Save the patches and augment as requested
    counter = 0;

    % This didn't work well and is unnecessary with newer datasets
    if addBlank
        fprintf('Running blanks\n');
        blankLabel = zeros(patchSize, "uint8");
        % Totally blank to weak background noise
        for i = 0:6
            counter = counter + 1;
            blankImage = uint8(i) + zeros(patchSize, "uint8");
            imwrite(blankImage, getImagePath(saveDir, dsetNo, counter));
            imwrite(blankLabel, getLabelPath(saveDir, dsetNo, counter));

            if aRot
                counter = counter + 1;
                tform = randomAffine2d(Rotation=[20 45]);
                outputView = affineOutputView(patchSize, tform);
                imwrite(imwarp(blankImage, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(blankLabel, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));

                counter = counter + 1;
                tform = randomAffine2d(Rotation=[-45 -20]);
                outputView = affineOutputView(patchSize, tform);
                imwrite(imwarp(blankImage, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(blankLabel, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));
            end
        end
    end

    for i = 1:numPatchesY
        for j = 1:numPatchesX
            counter = counter + 1;
            imwrite(patches{i,j}, getImagePath(saveDir, dsetNo, counter));
            imwrite(rois{i,j}, getLabelPath(saveDir, dsetNo, counter));

            if vFlip
                counter = counter + 1;
                imwrite(flipud(patches{i,j}), getImagePath(saveDir, dsetNo, counter));
                imwrite(flipud(rois{i,j}), getLabelPath(saveDir, dsetNo, counter));
            end

            if hFlip
                counter = counter + 1;
                imwrite(fliplr(patches{i,j}), getImagePath(saveDir, dsetNo, counter));
                imwrite(fliplr(rois{i,j}), getLabelPath(saveDir, dsetNo, counter));
            end

            if bFlip
                counter = counter + 1;
                imwrite(flipud(fliplr(patches{i,j})), getImagePath(saveDir, dsetNo, counter)); %#ok<FLUDLR>
                imwrite(flipud(fliplr(rois{i,j})), getLabelPath(saveDir, dsetNo, counter)); %#ok<FLUDLR>
            end

            if hvShear
                tform = randomAffine2d(XShear=[-30 30]);
                outputView = affineOutputView(patchSize, tform);
                counter = counter + 1;
                imwrite(imwarp(patches{i,j}, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(rois{i,j}, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));


                tform = randomAffine2d(YShear=[-30 30]);
                outputView = affineOutputView(patchSize, tform);
                counter = counter + 1;
                imwrite(imwarp(patches{i,j}, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(rois{i,j}, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));
            end

            if aRot
                tform = randomAffine2d(Rotation=[20 45]);
                outputView = affineOutputView(patchSize, tform);
                counter = counter + 1;
                imwrite(imwarp(patches{i,j}, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(rois{i,j}, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));


                tform = randomAffine2d(Rotation=[-45 -20]);
                outputView = affineOutputView(patchSize, tform);
                counter = counter + 1;
                imwrite(imwarp(patches{i,j}, tform, 'OutputView', outputView),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imwarp(rois{i,j}, tform, 'OutputView', outputView),...
                    getLabelPath(saveDir, dsetNo, counter));
            end

            if reSize
                counter = counter + 1;
                imwrite(imresize(patches{i,j}, 1.5, 'nearest', 'OutputSize', patchSize),...
                    getImagePath(saveDir, dsetNo, counter));
                imwrite(imresize(patches{i,j}, 1.5, 'nearest', 'OutputSize', patchSize),...
                    getImagePath(saveDir, dsetNo, counter));
            end

            if i == 1 && j == 1
                fprintf('Saving %u versions of each patch\n', counter);
            end
        end
    end

    fprintf('Saved %d patches from %d sections\n', counter, numPatchesX*numPatchesY);
end

function out = jitterGrayscale(im)
    im = im2double(im);
    cFac = 1-0.2*rand;
    bOff = 0.3*(rand-0.5);
    im = im .* cFac + bOff;
    out = im2uint8(im);
end


function out = getImagePath(saveDir, imageNo, patchNo)
    out = fullfile(saveDir, 'images',...
        sprintf('Image%d_Patch%d.tif', imageNo, patchNo));
end

function out = getLabelPath(saveDir, imageNo, patchNo)
    out = fullfile(saveDir, 'labels',...
        sprintf('Image%d_Label%d.tif', imageNo, patchNo));
end