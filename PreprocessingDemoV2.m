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
convertAviDual(experimentDir, [2:24, 26:34, 36]);

% Register the videos using Qiang's software.

%% Convert to .tif files and create snapshots for segmentation
% Now we process the registered videos to extract the useful information and
% create a record of the relevant data that is fast to load into MATLAB and
% takes up a minimal amount of the computer's memory.

[videoNames, p] = processVideoPrep( ...
    experimentDir, epochIDs, ...
    "ImagingSide", 'right', "ImageSize", [496 496],...
    "Registration", 'strip');
% ImageSize is the size of your videos in pixels. Registration is 'strip' or
% 'frame'. ImagingSide is 'right' or 'left' and specifies which part of the
% video to keep. Use 'full' to keep the whole video. See the help for
% processVideoPrep for more input options.

% You will get warnings if registered videos aren't found for any of the
% supplied epochIDs. If multiple registered videos are found, the last will
% be used (check processVideoPrep documentation for more). Ensure everything
% is in place before running the next line of code.

%% Create analysis files
run('PreprocessFunctionalImagingData.m');

%% MATLAB object
% Now we create a MATLAB object that contains all the relevant information
% for the experiment. After this step, all the interaction you do with the
% experiment data will be through this object.


% The processing is different for LED and spatial  stimuli, so there are two
% subclasses.

% SPATIAL ------------------------------------------------------------------
MC00851_ODR_20230821A = ao.core.Dataset(...
    exptDate, 851, epochIDs, 561, experimentDir, ...
    'ImagingSide', 'right', 'Eye', 'OD', ...
    'Defocus', 0.35, 'FieldOfView', [3.37 2.70], ...
    'Pinhole', 25);
% We have to specify the image size to import the ImageJ ROIs.
MC00851_ODR_20230821A.imSize = [242 390];
% Find the .tif files for each epoch's registered videos
MC00851_ODR_20230821A.getRegisteredVideoNames();

% Save the object.
save('MC00851_ODR_20230821A', 'MC00851_ODR_20230821A');

% LEDS ---------------------------------------------------------------------
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

tformFileName = '851_ODR_20230821_rigid_ref0020.txt';
MC00851_ODR_20230821B.loadTransforms(fullfile(...
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

% I save again at this point
save('MC00851_ODR_20230821B', 'MC00851_ODR_20230821B');

%% Summary stacks
% Make the following in ImageJ:
% - A stack of the SIFT-registered STD snapshots and of the SUM snapshots.
%   Save these as .tif files in the Analysis folder
% - Run bleach correction on the SUM and STD stacks and save as .tif files.
% - A Z-projection of the SUM stack (SUM projection) and the STD stack
%   (AVG projection). Running the bleach correction on the stack first can
%   improve the quality of the projections. These are the images we use for
%   coregistration and in talks/papers. I save them as .png files.

% Load the SUM projection of the SUM stack as a reference image. This will
% be used for coregistration and ROI identification.
MC00851_ODR_20230821B.setAvgImage(fullfile(experimentDir,...
    'Analysis', '851_ODR_20230821_SUM_DUP_SUM.png'));


%% Segmentation
% See the "Using ImageJ's RoiManager" for details on how to create the ROIs.

% Once you have some ROIs to import, load them here
MC00851_ODR_20230821B.loadROIs(fullfile(experimentDir, 'Analysis', ...
    '851_ODR_20230821_RoiSet.zip'));
% Now the file name is saved in the "roiFileName" property and you can
% reload it at any point.
MC00851_ODR_20230821B.reloadRois();

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

% Access ROI traces for specific epochs
[signals, xpts] = MC00851_ODR_20230821B.getEpochResponses(2, [250 498]);
plot(xpts, signals);

% Access ROI traces for several epochs and average
[signals, xpts] = MC00851_ODR_20230821B.getEpochResponses(...
    [2 3 4], [250 498], "Smooth", 100, "Average", true);

