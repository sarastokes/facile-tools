%% Post-processing pipeline


experimentDir = 'C:\Users\spatterson\Desktop\MC00851_20230821\';
epochIDs = [2:24, 26:34, 36];
exptDate = '20230821';

%% AVI fix and registration
% The avi codec used for writing responses to the LED stimuli is not
% compatible with the latest version of Qiang's registration software.
% This writes the AVI files using a different codec and appends an "O" to
% the end of the file name to distinguish the videos from the originals.
convertAvi(fullfile(experimentDir, 'Ref'), [2:24, 26:34, 36]);
convertAvi(fullfile(experimentDir, 'Ref'), [2:24, 26:34, 36]);

% Next register the videos in Qiang's software. Make sure to check torsion
% control and set subpixel to 1/4 in the settings tab of the toolbar.

%% Convert to .tif files and create snapshots for segmentation
% Now we process the registered videos to extract the useful information and
% create a record of the relevant data that is fast to load into MATLAB and
% takes up a minimal amount of the computer's memory.

[videoNames, p] = processVideoPrep( ...
    experimentDir, epochIDs, ...
    "ImagingSide", 'right', "FieldOfView", [496 496],...
    "Registration", 'strip', "Reflect", true);
% FieldOfView is the size of your videos in pixels. Reflect flips the image
% and should be set to true (the latest update of Qiang's software flips the
% videos for some reason so we have to flip them back to compare with prior
% data. Registration is 'strip' or 'frame'. ImagingSide is 'right' or 'left'
% and specifies which part of the video to keep.

MC00851_ODR_20230821B = ao.core.DatasetLED2(...
    exptDate, 851, epochIDs, experimentDir, ...
    'ImagingSide', 'right', 'Eye', 'OD', ...
    'Defocus', 0.35, 'FieldOfView', [3.37 2.70], ...
    'Pinhole', 25);
% The required inputs are the experiment date, the animal ID, the epoch IDs
% and the experiment directory.
% Note: you will get a few warnings related to the "background" epoch 36
% because it does not have stimulus files associated with it. This is fine
% to ignore.

% We have to specify the image size to import the ImageJ ROIs.
MC00851_ODR_20230821B.imSize = [242 390];
% Find the .tif files of each epoch's registrered videos
MC00851_ODR_20230821B.getRegisteredVideoNames();
% Automatically identify stimulus names from the text files.
MC00851_ODR_20230821B.getStimuli();

save('MC00851_ODR_20230821B', 'MC00851_ODR_20230821B');

%% SIFT Registration
% In ImageJ:
% - Create SUM stack with all epoch snapshots (except background)
% - Sort by label
% - Duplicate the best and move to front of stack
% - Run histogram matching in "Bleach correction" plugin
% - Clear the log
% - Perform SIFT transform (rigid)
% - Save results in log as .txt file

MC00851_ODR_20230814B.loadTransforms(fullfile(...
    experimentDir, 'Analysis', TFORM_NAME),...
    epochIDs(1:end-1));
% First input is the file name, second input is the epoch IDs (here the
% background epoch is excluded).

% Remake the stack snapshots with the SIFT transforms applied. Open again in
% ImageJ to confirm the registration applied correctly.
MC00851_ODR_20230821B.clearVideoCache();
MC00851_ODR_20230821B.makeStackSnapshots();

% Make a Z-projection of the registered stack in ImageJ and save it as a
% .png file. This will be the image used when coregistering
MC00851_ODR_20230814B.avgImage = im2double(imread(fullfile(experimentDir,...
    'Analysis', '851_ODR_20230821_SUM_DUP_SUM.png')));

%% Segmentation
% Once you have some ROIs to import, load them here
MC00851_ODR_20230821B.loadROIs(fullfile(experimentDir, 'Analysis', ...
    '851_ODR_20230821_RoiSet.zip'));
% Now the file name is saved in the "roiFileName" property and you can
% reload it at any point.
