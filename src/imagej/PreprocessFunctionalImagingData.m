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
%   04Sep2023 - SSP - Added background subtraction for v low SNR data
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
createAnalysisFolders(p.experimentDir);
snapshotDir = fullfile(p.experimentDir, 'Analysis', 'Snapshots');

% Connect to imagej (if connection does not already exist)
run('ConnectToImageJ.m');
import ij.*;

% Prep background region, if needed
if ~isempty(p.BackgroundRegion)
    x0 = p.BackgroundRegion(1);
    x = p.BackgroundRegion(3);
    y0 = p.BackgroundRegion(2);
    y = p.BackgroundRegion(4);
end

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

    if p.UsingLEDs
        % Pre-2022 LED file naming scheme
        newTitle = ['vis#', int2fixedwidthstr(epochID, 3)];
    else % Current 1P AOSLO file naming scheme
        newTitle = ['vis_', int2fixedwidthstr(epochID, 4)];
    end
    if p.Channel == "ref"
        newTitle = strrep(newTitle, "vis", "ref");
    end
    fprintf('Saving as %s... ', newTitle);

    % Reflect, if needed
    if p.Reflect
        IJ.run("Flip Vertically", "stack");
    end

    % Identify background value from specified region, if necessary
    if ~isempty(p.BackgroundRegion)
        curVidName = getTitle(IJ.getImage());
        IJ.run("Specify...", java.lang.String(['width=', num2str(x), ' height=', num2str(y), ' x=', num2str(x0), ' y=', num2str(y0), ' slice=1']));
        IJ.run("Duplicate...", java.lang.String(['title=', 'tmp', ' duplicate']));
        curBkgdName = getTitle(IJ.getImage());
        IJ.run("Z Project...", "projection=[Average Intensity]");

        IJM.getDatasetAs('vid');
        p.BackgroundValue = mean(vid, "all");
        openImg = IJ.getImage();
        openImg.close();
        IJ.selectWindow(java.lang.String(['tmp']));
        openImg = IJ.getImage();
        openImg.close();

        IJ.selectWindow(java.lang.String([curVidName]));
    end

    if ~isempty(p.XLim)
        IJ.run("Specify...", java.lang.String(sprintf("width=%d height=%d x=%d y=%d",...
            p.XLim(2)-p.XLim(1), p.YLim(2)-p.YLim(1), p.XLim())))
    end

    % Crop to a standardized size, if needed (default "full" doesn't crop)
    if ~isempty(char(p.ImagingSide)) && ~strcmp(p.ImagingSide, 'full') && ~isempty(p.FieldOfView)
        txt = getLegacyFovCropString(p);
        if txt ~= ""
            IJ.run("Specify...", txt);
        end
    end

    IJ.run("Duplicate...", java.lang.String(['title=', newTitle, ' duplicate']));

    % Subtract background value, if necessary
    if p.BackgroundValue > 0
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