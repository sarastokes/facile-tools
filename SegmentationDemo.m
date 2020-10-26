% Segmentation Demo
% - Recreates the processing shown in Segmentation Demo slideshow
%
% 25Aug2020 - SSP
% 26Oct2020 - SSP - added comments 
% --

% Make sure to add facile-tools folder and subfolders to matlab path
addpath(genpath('...\facile-tools'));  % Edit to your file location

% Load in the demo image
im = imread(imgetfile());
im = im2double(im);

figure(); imshow(im, []);
title('Original Image');

%% Filter the image
[imFiltered, imTop, imBot] = topbotFilter(im, 8);

% Compare to original
figure(); imshowpair(im, imFiltered, 'montage');
title('Original and Filtered Images');

% Two ways of looking at underlying top/bottom-hat filtered images
figure(); imshowpair(imTop, imBot);
title('Top and Bottom-Hat Filtered Images');

figure(); imshowpair(imTop, imBot, 'montage');
title('Top and Bottom-Hat Filtered Images');

%% Segmentation
% These parameters are largely consistent b/w datasets collected with 
% similar parameters (e.g. pinhole size)
[regions, rois] = runPlotMSER(imFiltered,...
    'RegionAreaRange', [25, 140],... 
    'ThresholdDelta', 1.5,... 
    'MaxAreaVariation', 0.3);
% Note that plotting is the most time consuming (see speed test below)

% Returns 7683 ROIs!
% Details about MSER feature detection (and why there are so many ROIs):
doc('detectMSERFeatures')

%% View ROIs
roiOverlay(im, rois);
title('ROIs and Original Image');

% The "pink" colormap is a log scale and pulls out low signal areas
roiOverlay(imFiltered, rois, 'Colormap', 'pink');  
title('ROIs and Filtered Image');


%% Parse ROIs
% Show ROIs by perimeter - many of the ROIs encompassing 2 cells can be 
% identified by their larger perimeters
roiColorByStat(rois, 'Perimeter');
% Keep only the ROIs with perimeters less than 57 pixels
[regions, rois] = roiStatFilter(regions, rois, 'Perimeter', @(x) x < 57);
% Removed 173 of 7683 objects. 7510 remain.

% The weird ROIs on the edges can be detected bc they aren't circles
S = roiColorByStat(rois, 'Eccentricity');
% To see the ROIs you will remove before filtering:
roiOverlay(im, ismember(labelmatrix(rois), find(S >= 0.95)));
% Looks good, so filter
[regions, rois] = roiStatFilter(regions, rois, 'Eccentricity', @(x) x < 0.95);
% Removed 189 of 7510 objects. 7321 remain

% Remove erroneous ROIs that are located in background between ROIs
% These ROIs will have a high intensity on the bottom-hat filtered image
S = roiColorByStat(rois, 'MeanIntensity', 'Image', imBot);
ind = ~isoutlier(S);
fprintf('Found %u outliers between %.3f and %.3f\n',... 
    nnz(~ind), min(S(~ind)), max(S(~ind)));
[region, rois] = roiFilter(regions, rois, ind);
% Removed 706 of 7321 objects. 6615 remain

% roiColorByStat and roiStatFilter rely on a MATLAB function called 
% "regionprops". The documentation has the full list of ROI attributes 
% that can be used to filter ROIs.
doc('regionprops')

% Now remove all the extraneous remaining ROIs
[regions, rois] = roiCleanup(regions, rois);
% Removed 6016 of 6615 objects. 599 remain

%% See ROI signals
load('imStack');  % Load in the video (as .mat)
RoiSignalView(imStack, rois, 25);
% Use the arrow keys to navigate through ROIs

%% Speed test
tic
[imFiltered, ~, imBot] = topbotFilter(im, 8);
% Don't use runPlotMSER bc plotting is time-consuming
[regions, rois] = runPlotMSER(imFiltered,...
    'RegionAreaRange', [25, 140],...
    'ThresholdDelta', 1.5,...
    'MaxAreaVariation', 0.3,...
    'Plot', false);

[regions, rois] = roiStatFilter(regions, rois, 'Perimeter', @(x) x < 57);
[regions, rois] = roiStatFilter(regions, rois, 'Eccentricity', @(x) x < 0.95);
S = roiColorByStat(rois, 'MeanIntensity', 'Image', imBot);
[regions, rois] = roiFilter(regions, rois, ~isoutlier(S));

[regions, rois] = roiCleanup(regions, rois);  
toc

% For my desktop computer: Elapsed time is 2.812788 seconds
% My laptop was around 8 seconds