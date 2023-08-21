% PreprocessFunctionalImagingData.m
%
% Description:
%   Communicates with ImageJ to convert registered .avi files into .tif
%   files and stack snapshots.
%
% Requires the following variables in base workspace:
%   p               struct
%       Output from processVideoPrep.m
%
% Use:
%   [videoNames, p] = processVideoPrep(experimentDir, epochIDs,...
%       'ImagingSide', 'right', UsingLEDs', false);
%   run('PreprocessFunctionalImagingData.m');
%
% See also:
%   processVideoPrep
%
% History:
%   01Nov2021 - SSP
%   17Nov2021 - SSP - Added LED file compatibility
%   06Dec2021 - SSP - Changed 'baseDir' to 'experimentDir'
%   10Jun2023 - SSP - Option for reflectance video processing
%   27Jun2023 - SSP - Added default creation of analysis folders
% -------------------------------------------------------------------------

% Variable validation
if ~exist('p', 'var')
    error('No variable named ''p'' found! See help for more info');
end
if ~exist('videoNames', 'var')
    error('No variable named ''videoNames'' found! See help for more info');
end

% Identify experiment folder and analysis subfolders (create if absent)
if p.experimentDir(end) ~= filesep
    p.experimentDir = [p.experimentDir, filesep];
end
if ~isfolder(fullfile(p.experimentDir, 'Analysis'))
    mkdir(fullfile(p.experimentDir, 'Analysis'));
end
snapshotDir = fullfile(p.experimentDir, 'Analysis', 'Snapshots');
if ~isfolder(snapshotDir)
    mkdir(snapshotDir);
end
videoDir = fullfile(p.experimentDir, 'Analysis', 'Videos');
if ~isfolder(videoDir)
    mkdir(videoDir);
end

%expName = strsplit(p.experimentDir, filesep);

% Connect to imagej (if connection does not already exist)
run('ConnectToImageJ.m');
import ij.*;

% Loop through the epochs creating a video and snapshots
k = videoNames.keys;
progressbar();
for i = 1:numel(k)
    % Video identifier
    epochID = str2double(k{i});

    % Images associated with this ID
    iNames = videoNames(k{i});
    for j = 1:numel(iNames)
        IJ.run("AVI...", java.lang.String("select=" + iNames(j) + " avi=" + iNames(j)));
            disp(iNames(j));
    end

    if numel(iNames) > 1
        IJ.run("Concatenate...", "all_open open");
    end

    if p.UsingLEDs
        newTitle = ['vis#', int2fixedwidthstr(epochID, 3)];
    else
        newTitle = ['vis_', int2fixedwidthstr(epochID, 4)];
    end
    if p.Channel == "ref"
        newTitle = strrep(newTitle, "vis", "ref");
    end
    disp(newTitle);

    % Reflect, if needed
    if p.Reflect
        IJ.run("Flip Vertically");
    end

    % Crop, if needed
    switch p.ImagingSide
        case 'left'
            IJ.run("Specify...", "width=248 height=360 x=0 y=0 slice=1");
        case 'right'  % 20220308 on
            if p.FieldOfView == [496 360]
                IJ.run("Specify...", "width=242 height=360 x=254 y=0 slice=1");
            elseif p.FieldOfView == [496 496] % skipping row at top and bottom
                IJ.run("Specify...", "width=242 height=494 x=254 y=1 slice=1");
            elseif p.FieldOfView == [496 408]
                IJ.run("Specify...", "width=240 height=406 x=255 y=1 slice=1");
            end
        case 'right_smallFOV'
            IJ.run("Specify...", "width=120 height=360 x=376 y=0 slice=1");
        case 'top'
            IJ.run("Specify...", "width=496 height=168 x=0 y=240 slice=1");
    end

    % Save the new stack
    IJ.run("Duplicate...", java.lang.String(['title=', newTitle, ' duplicate']));

    savePath = fullfile(videoDir, [newTitle, '.tif']);
    IJ.saveAs("Tiff", java.lang.String(savePath));

    % AVG Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Average Intensity]");
    savePath = fullfile(snapshotDir, ['AVG_', newTitle, '.png']);
    IJ.saveAs("PNG", java.lang.String(savePath));
    openImg = IJ.getImage();
    openImg.close();

    % SUM Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Sum Slices]");
    savePath = fullfile(snapshotDir, ['SUM_', newTitle, '.png']);
    IJ.saveAs("PNG", java.lang.String(savePath));
    openImg = IJ.getImage();
    openImg.close();

    % STD Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Standard Deviation]");
    savePath = fullfile(snapshotDir, ['STD_', newTitle, '.png']);
    IJ.saveAs("PNG", java.lang.String(savePath));
    openImg = IJ.getImage();
    openImg.close();

    % Close out
    IJ.run('Close All');

    % Update progress bar
    progressbar(i / numel(k));
end
progressbar(1);

% Clean up workspace
clear i j k iNames newTitle source expIDs epochID baseName expDate
clear openImg img fijiDir makeSummary
clear snapshotDir videoDir