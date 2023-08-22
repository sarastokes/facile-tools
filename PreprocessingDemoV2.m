%% Post-processing pipeline
% The goal here is to consolidate the information related to the experiment
% into a single place (a MATLAB object) and then reduce the size of the
% data that has to be stored on the computer in order to analyze it. We also
% need to correct for residual errors not addressed by Qiang's software.

experimentDir = 'C:\Users\spatterson\Desktop\MC00851_20230821\';
epochIDs = [2:24, 26:34, 36];
exptDate = '20230821';

%% AVI fix and registration
% The avi codec used for writing responses to the LED stimuli is not
% compatible with the latest version of Qiang's registration software.
% This writes the AVI files using a different codec and appends an "O" to
% the end of the file name to distinguish the videos from the originals.
convertAvi(fullfile(experimentDir, 'Ref'), [2:24, 26:34, 36]);
convertAvi(fullfile(experimentDir, 'Vis'), [2:24, 26:34, 36]);

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

% You will get warnings if registered videos aren't found for any of the
% supplied epochIDs


%% MATLAB object
% Now we create a MATLAB object that contains all the relevant information
% for the experiment. After this step, all the interaction you do with the
% experiment data will be through this object.
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

% Loading the JSON files takes awhile so I usually save the object at this
% point so I don't have to do it again.
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
% - Save original stack (useful if you decide to change transform later)

tformFileName = '';
MC00851_ODR_20230814B.loadTransforms(fullfile(...
    experimentDir, 'Analysis', tformFileName),...
    epochIDs(1:end-1));
% First input is the file name, second input is the epoch IDs (here the
% background epoch is excluded).

%% Check the registration
% Remake the stack snapshots with the SIFT transforms applied. Open again in
% ImageJ to confirm the registration applied correctly.
MC00851_ODR_20230821B.clearVideoCache();
MC00851_ODR_20230821B.makeStackSnapshots();

% If the transforms applied correctly, you are good to go and no longer need
% the contents of Ref and Vis. I usually on keep the Analysis folder
% contents available on my computer/Dropbox. Ref and Vis can go to the NAS.

% Make the following in ImageJ:
% - A stack of the SIFT-registered STD snapshots and of the SUM snapshots.
% - A Z-projection of the SUM stack (SUM projection) and the STD stack
%   (AVG projection). Running the bleach correction on the stack first can
%   improve the quality of the projections. These are the images we use for
%   coregistration and in talks/papers.


%% Segmentation
% Make a Z-projection of the registered stack in ImageJ and save it as a
% .png file in the Analysis folder. This will be used when coregistering
zProjFileName = '851_ODR_20230821_SUM_DUP_SUM.png';
MC00851_ODR_20230814B.setAvgImage(fullfile(experimentDir,...
    'Analysis', '851_ODR_20230821_SUM_DUP_SUM.png'));

% Once you have some ROIs to import, load them here
MC00851_ODR_20230821B.loadROIs(fullfile(experimentDir, 'Analysis', ...
    '851_ODR_20230821_RoiSet.zip'));
% Now the file name is saved in the "roiFileName" property and you can
% reload it at any point.

%% File structure
% You should now have the following in your Analysis folder
%       - *Videos*       (folder; .tif of each video cropped to the analysis region)
%       - *Snapshots*    (folder; SUM, STD and AVG Z projections of each epoch)
%       - RoiSet.zip                            (Segmentation)
%       - sift_transform.txt                    (SIFT tranform information)
%       - Original_851_ODR_20230821_SUM.tif     (Original stack of SUM snapshots)
%       - 851_ODR_20230821_SUM_DUP.tif          (stack of SUM snapshots)
%       - 851_ODR_20230821_SUM_DUP_SUM.png      (SUM z-projection of SUM stack)
%       - 851_ODR_20230821_STD_DUP.tif          (stack of STD snapshots)
%       - 851_ODR_20230821_STD_DUP_AVG.png      (AVG z-projection of STD stack)

%% Useful functions
% Click "Go" on any stimulus to open up the ROI viewer UI
ExperimentHome(MC00851_ODR_20230821B);