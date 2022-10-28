% MAKESUMMARYSTACKS
%
% Requirements to run are the same as PreprocessFunctionalImagingData.m
%
% History:
%   06Dec2021 - SSP
%   06Aug2022 - SSP - fixed for Mac
% -------------------------------------------------------------------------

run('ConnectToImageJ.m');
import ij.*;

analysisDir = fullfile(p.experimentDir, 'Analysis');
snapshotDir = fullfile(analysisDir, 'Snapshots');

txt = strsplit(p.experimentDir, filesep);
expNameShort = txt{end-1};

if startsWith(expNameShort, 'MC')
    expNameShort = expNameShort(3:end);
end

while startsWith(expNameShort, '0')
    expNameShort = expNameShort(2:end);
end

% AVG stack
for i = 1:numel(epochIDs)
    ID = int2fixedwidthstr(epochIDs(i), 4);
    IJ.open(java.lang.String(fullfile(snapshotDir, ['AVG_vis_', ID, '.png'])));
end
IJ.run("Images to Stack");
IJ.selectWindow(java.lang.String('Stack'));
stackPath = fullfile(analysisDir, [expNameShort, '_AVG.tif']);
IJ.saveAs("Tiff", java.lang.String(stackPath));

IJ.run("Z Project...", "projection=[Sum Slices]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_SUM.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run("Z Project...", "projection=[Average Intensity]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_AVG.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run('Close All');

% SUM stack
for i = 1:numel(epochIDs)
    ID = int2fixedwidthstr(epochIDs(i), 4);
    IJ.open(java.lang.String(fullfile(snapshotDir, ['SUM_vis_', ID, '.png'])));
end
IJ.run("Images to Stack");
IJ.selectWindow(java.lang.String('Stack'));
stackPath = fullfile(analysisDir, [expNameShort, '_SUM.tif']);
IJ.saveAs("Tiff", java.lang.String(stackPath));

IJ.run("Z Project...", "projection=[Sum Slices]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_SUM.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run("Z Project...", "projection=[Average Intensity]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_AVG.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run('Close All');

% STD stack
for i = 1:numel(epochIDs)
    ID = int2fixedwidthstr(epochIDs(i), 4);
    IJ.open(java.lang.String(fullfile(snapshotDir, ['STD_vis_', ID, '.png'])));
end
IJ.run("Images to Stack");
IJ.selectWindow(java.lang.String('Stack'));
stackPath = fullfile(analysisDir, [expNameShort, '_STD.tif']);
IJ.saveAs("Tiff", java.lang.String(stackPath));

IJ.run("Z Project...", "projection=[Sum Slices]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_SUM.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run("Z Project...", "projection=[Average Intensity]");
IJ.run("Enhance Contrast", "saturated=0.35");
IJ.saveAs("PNG", java.lang.String(replace(stackPath, '.tif', '_AVG.png')));
openImg = IJ.getImage();
openImg.close();

IJ.run('Close All');

% Clean up workspace
clear analysisDir snapshotDir stackPath txt expNameShort

