function [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionDatastores(imds, pxds, labelIDs, parSize)
% PARTITIONDATASTORE Partition into test, validation and training sets
%
% Syntax:
%   [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionDatastore(imds, pxds, labelIDs)
%
% Adapted from:
%   https://www.mathworks.com/matlabcentral/answers/1614330-how-to-split-imagedatastore-and-pixellabeldatastore

    if nargin < 4
        parSize = [80 10 10]/100;
    end

    % rng(0)
    numFiles = numel(imds.Files);
    shuffledIndices = randperm(numFiles);

    % Use 80% of the images for training.
    numTrain = round(parSize(1) * numFiles);
    trainingIdx = shuffledIndices(1:numTrain);

    % Use 10% of the images for validation
    numVal = round(parSize(2) * numFiles);
    valIdx = shuffledIndices(numTrain+1:numTrain+numVal);

    % Use the rest for testing.
    if numel(parSize) == 3
        numVal = round(parSize(3) * numFiles);
        testIdx = shuffledIndices(numTrain+numVal+1:end);
    else
        testIdx = valIdx;
    end

    % Create image datastores for training and test.
    trainingImages = imds.Files(trainingIdx);
    valImages = imds.Files(valIdx);
    testImages = imds.Files(testIdx);
    imdsTrain = imageDatastore(trainingImages);
    imdsVal = imageDatastore(valImages);
    imdsTest = imageDatastore(testImages);

    % Extract class and label IDs info.
    classes = pxds.ClassNames;

    % Create pixel label datastores for training and test.
    trainingLabels = pxds.Files(trainingIdx);
    pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
    valLabels = pxds.Files(valIdx);
    pxdsVal = pixelLabelDatastore(valLabels, classes, labelIDs);
    testLabels = pxds.Files(testIdx);
    pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);

    fprintf('Partitioned into:\n\tTrain: %u\n\tValidation: %u\n\tTest: %u\n',...
        numel(pxdsTrain.Files), numel(pxdsVal.Files), numel(pxdsTest.Files));

    % Combine into pixelLabelDatastores if needed
    if nargout == 3
        imdsTrain = combine(imdsTrain, pdxsTrain);
        imdsVal = combine(imdsVal, pdxsVal);
        imdsTest = combine(imdsTest, pdxsTest);
    end
