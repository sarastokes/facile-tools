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
% -------------------------------------------------------------------------

% Variable validation
if ~exist('p', 'var')
    error('No variable named ''p'' found! See function help for more info');
end

if p.experimentDir(end) ~= filesep
    p.experimentDir = [p.experimentDir, filesep];
end

expName = strsplit(p.experimentDir, filesep);

k = videoNames.keys;

run('ConnectToImageJ.m');
import ij.*;

% FOR LOOP STARTS HERE
progressbar();
for i = 1:numel(k)

    % Video identifier
    epochID = str2double(k{i});
    
    % Images associated with this ID
    iNames = videoNames(k{i});
    for j = 1:numel(iNames)
        % if ispc
        %     img = IJ.openImage(java.lang.String(iNames(j)));
        %     fprintf('Epoch %u has %u frames\n', p.epochIDs(i), img.getStackSize());
        %     img.show();
        % else
            IJ.run("AVI...", java.lang.String("select=" + iNames(j) + " avi=" + iNames(j)));
            disp(iNames(j));
        % end
    end
    
    if numel(iNames) > 1
        IJ.run("Concatenate...", "all_open open");
    end
    
    if p.UsingLEDs
        newTitle = ['vis#', int2fixedwidthstr(epochID, 3)];
    else
        newTitle = ['vis_', int2fixedwidthstr(epochID, 4)];
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
        case 'right_old'  % Used before 20220308
            IJ.run("Specify...", "width=248 height=360 x=250 y=0 slice=1");
        case 'right'  % 20220308 on
            IJ.run("Specify...", "width=242 height=360 x=254 y=0 slice=1");
        case 'right_smallFOV'
            IJ.run("Specify...", "width=120 height=360 x=376 y=0 slice=1");
        case 'top'
            IJ.run("Specify...", "width=496 height=168 x=0 y=240 slice=1");
    end

    % Save the new stack
    IJ.run("Duplicate...", java.lang.String(['title=', newTitle, ' duplicate']));

    savePath = fullfile(p.experimentDir, 'Analysis', 'Videos', [newTitle, '.tif']);
    IJ.saveAs("Tiff", java.lang.String(savePath));

    % AVG Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Average Intensity]");
    savePath = fullfile(p.experimentDir, 'Analysis', 'Snapshots', ['AVG_', newTitle, '.png']);
    IJ.saveAs("PNG", java.lang.String(savePath));
    openImg = IJ.getImage();
    openImg.close();

    % MAX Z-projection (wasn't useful)
    % IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    % IJ.run("Z Project...", "projection=[Max Intensity]");
    % savePath = [p.experimentDir, 'Analysis\Snapshots\MAX_', newTitle, '.png'];
    % IJ.saveAs("PNG", java.lang.String(savePath));
    % openImg = IJ.getImage();
    % openImg.close();

    % SUM Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Sum Slices]");
    savePath = fullfile(p.experimentDir, 'Analysis', 'Snapshots', ['SUM_', newTitle, '.png']);
    IJ.saveAs("PNG", java.lang.String(savePath));
    openImg = IJ.getImage();
    openImg.close();

    % STD Z-projection
    IJ.selectWindow(java.lang.String([newTitle, '.tif']));
    IJ.run("Z Project...", "projection=[Standard Deviation]");
    savePath = fullfile(p.experimentDir, 'Analysis', 'Snapshots', ['STD_', newTitle, '.png']);
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