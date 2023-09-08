%% 20230628
% --


%% Test Image-MATLAB connection
% Only need to do this step once:
setpref('AOData', 'FijiScripts', 'C:\Users\SPATTE~1\DOCUME~1\Fiji.app\scripts\');
run('ConnectToImageJ.m');

%% Basic information about experiment
epochIDs = [18:22, 25:40, 42:48];
exptFolder = "C:\Users\spatterson\Dropbox\Postdoc\Data\AO\MC00851_20230627\";
exptName = '851_ODR_20230627';

%% Preprocessing
[videoNames, p] = processVideoPrep(exptFolder, epochIDs,...
    "ImagingSide", 'right', "Registration", 'strip',...
    "UseFirst", false);

run('PreprocessFunctionalImagingData.m');

% In ImageJ
% - Create SummaryStacks
% - Sort by label, duplicate the best and move to front of stack
% - Run histogram matching in "Bleach correction" plugin
% - Clear the log
% - Perform SIFT transform
% - Save results in log as .txt file

%% Create the object
obj = SimpleDataset(exptName, exptFolder, epochIDs);
obj.imSize = [242, 360];


%% Load the transforms
obj.addTransforms('851_ODR_20230627_rigid_ref0025_sum.txt');

% Remake the stack snapshots
obj.clearVideoCache();
obj.makeStackSnapshots();

% In ImageJ:
% - Make sure the registration looks acceptable
% - Make a Z-projection of the SUM stack and save

%% Set the average image:
obj.setAvgImage('851_ODR_20230627_SUM_DUP_SUM.png');

%% Access your post-registered videos
imStack = obj.getEpochStack(18);

%% ROIs
obj.loadROIs('851_ODR_20230627_RoiSet.zip');
% Now the file name is saved in the "roiFileName" property and you can
% reload it at any point.
