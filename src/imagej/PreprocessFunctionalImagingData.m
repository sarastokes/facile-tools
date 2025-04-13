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
%       'ImagingSide', 'right', UsingOldLEDs', false);
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
%   04Sep2023 - SSP - Added background subtraction for v low SNR data
% -------------------------------------------------------------------------

% Variable validation
if ~exist('p', 'var')
    error('No variable named ''p'' found! See ''help processVideoPrep''');
end
if ~exist('videoNames', 'var')
    error('No variable named ''videoNames'' found! See ''help processVideoPrep''');
end

% Create Analysis folder and subfolders, if absent
createAnalysisFolders(p.experimentDir);
snapshotDir = fullfile(p.experimentDir, 'Analysis', 'Snapshots');
videoDir = fullfile(p.experimentDir, 'Analysis', 'Videos');

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
        fprintf('Processing %s...\n', iNames(j));
    end

    if numel(iNames) > 1
        IJ.run("Concatenate...", "all_open open");
    end

    % Get
    if ~isfield(p, 'ImageSize') || isempty(p.ImageSize)
        warning('Extracting FOV from video - could take awhile to import')
        IJM.getDatasetAs("videoData");
        p.ImageSize = size(videoData, [1 2]);
        clear videoData
    end

    if p.UsingOldLEDs
        % Pre-2022 LED file naming scheme
        newTitle = ['vis#', int2fixedwidthstr(epochID, 3)];
    else % Current 1P AOSLO file naming scheme
        newTitle = ['vis_', int2fixedwidthstr(epochID, 4)];
    end

    % Adjust if processing reflectance instead of fluorescence
    if p.Channel == "ref"
        newTitle = strrep(newTitle, "vis", "ref");
    end

    fprintf('Saving as %s... ', newTitle);

    % Reflect, if needed (for newer versions of ImageReg, >2021)
    if p.Reflect
        IJ.run("Flip Vertically", "stack");
    end

    if ~isfield(p, 'XLim') || isempty(p.XLim)
        if strcmpi(p.ImagingSide, 'right')
            p.XLim = [floor(p.ImageSize(1)/2)+1, p.ImageSize(1)];
        elseif strcmpi(p.ImagingSide, 'left')
            p.XLim = [0, floor(p.ImageSize(1)/2)];
        end
        p.YLim =[0 p.ImageSize(2)];
    end

    if ~isfield(p, 'YLim') || isempty(p.YLim)
        p.YLim = [0 p.ImageSize(2)];
    end

    if ~isempty(p.XLim)
        IJ.run("Specify...", java.lang.String(sprintf("width=%d height=%d x=%d y=%d",...
            p.XLim(2)-p.XLim(1), p.YLim(2)-p.YLim(1), p.XLim(1), p.YLim(1))));
    end

    IJ.run("Duplicate...", java.lang.String(['title=', newTitle, ' duplicate']));

    % Subtract background value, if necessary
    if isfield(p, 'BackgroundValue') && p.BackgroundValue > 0
        IJ.run("Subtract...", java.lang.String(['value=', num2str(p.BackgroundValue), ' stack']));
        fprintf('Subtracting %s...', num2str(p.BackgroundValue));
    end

    % Save the new stack
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
    fprintf('Done\n');

    % Update progress bar
    progressbar(i / numel(k));
end
progressbar(1);

% Clean up workspace
clear i j k iNames newTitle source expIDs epochID baseName expDate
clear openImg img fijiDir makeSummary vid bkgdValue x y x0 y0
clear snapshotDir videoDir