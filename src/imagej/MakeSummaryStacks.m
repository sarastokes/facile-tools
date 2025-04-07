% MAKESUMMARYSTACKS
%
% This script should be called by the function createSummaryStacks!
%
% See also:
%  createSummaryStacks
%
% History:
%   06Dec2021 - SSP
%   06Aug2022 - SSP - fixed for Mac
%   08Nov2024 - SSP - compatibility with createSummaryStacks()
% -------------------------------------------------------------------------

if ~exist("summaryStackParameters", "var")
    error("No variable named 'summaryStackParameters' found! See createSummaryStacks");
end

run('ConnectToImageJ.m');
import ij.*;

analysisDir = fullfile(summaryStackParams.experimentDir, 'Analysis');
snapshotDir = fullfile(analysisDir, 'Snapshots');

% AVG stack
for i = summaryStackParams.epochIDs
    fName = fullfile(snapshotDir, sprintf("AVG_vis_%04d.png", i));
    IJ.open(java.lang.String(fName));
end
IJ.run("Images to Stack");
IJ.selectWindow(java.lang.String('Stack'));
stackPath = fullfile(analysisDir, summaryStackParams.filePrefix + "_AVG.tif");
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
for i = summaryStackParams.epochIDs
    fName = fullfile(snapshotDir, sprintf("SUM_vis_%04d.png", i));
    IJ.open(java.lang.String(fName));
end
IJ.run("Images to Stack");
IJ.selectWindow(java.lang.String('Stack'));
stackPath = fullfile(analysisDir, summaryStackParams.filePrefix + "_SUM.tif");

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
for i = summaryStackParams.epochIDs
    fName = fullfile(snapshotDir, sprintf("STD_vis_%04d.png", i));
    IJ.open(java.lang.String(fName));
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
clear analysisDir snapshotDir stackPath txt expNameShort openImg fName i
