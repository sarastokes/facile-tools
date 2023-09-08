function plotTestLabels(imdsTest, predTest, rc)
%PLOTTESTLABELS
%
% Syntax:
%   imdsTest        matlab.io.datastore.ImageDatastore
%       The test images
%   predTest        matlab.io.datastore.PixelLabelDatastore
%       The predicted labels for the test images
%   rc              double [1, 2]
%       The number of rows and columns for the plot
%
% History:
%   30Aug2023 - SSP
% -------------------------------------------------------------------------

    arguments
        imdsTest    matlab.io.datastore.ImageDatastore
        predTest    matlab.io.datastore.PixelLabelDatastore
        rc          (1,2)   {mustBeInteger} = [4 5]
    end

    numRows = rc(1); numCols = rc(2);
    numPlots = rc(1) * rc(2);
    numFiles = numel(imdsTest.Files);

    imdsTest.reset();
    predTest.reset();

    figure();
    for i = 1:numFiles
        if i > numPlots || i > numFiles
            return
        end
        subplot(numRows, numCols, i);
        predLabel = predTest.read();
        predLabel = uint8(predLabel{1});
        B = labeloverlay(imadjust(imdsTest.read()), predLabel-1,...
            'Transparency', 0.7, 'Colormap', [1 0 0; 1 0 0]);
        imshow(B);
        drawnow;
    end
