function checkFrameCounts(folderName, epochIDs)
% CONVERTAVI
% 
% Description:
%   Converts Primate 1P system videos into a format readable by Qiang's
%   ImageReg software. Videos that have already been registered or
%   converted will be skipped. The new videos will have the same file name
%   as before, but with an "O" at the end.
%
% Syntax:
%   convertAvi(folderName, epochIDs)
%
% Inputs:
%   folderName          string/char
%       The folder containing the videos you want to convert
%   epochIDs            array of integers
%       The video numbers you want to convert
%
% Examples:
%   % Convert videos 1-10 in the "Ref" folder
%   convertAvi('C:/Users/yourname/MC00838_20221122/Ref', 1:10)

%   Sara Patterson, 2022 (facile-tools) 
% -------------------------------------------------------------------------

    arguments
        folderName      string      {mustBeFolder(folderName)}    
        epochIDs        double      {mustBeInteger(epochIDs)} 
    end

    allFiles = deblank(string(ls(folderName)));
    aviFiles = allFiles(endsWith(allFiles, ".avi"));
    % Remove registered videos
    rawFiles = aviFiles(~contains(aviFiles, ["frame", "strip"]));
    % Remove already converted videos
    % rawFiles = aviFiles(~endsWith(aviFiles, "O.avi"));
    visFolderName = strrep(folderName, '/Ref', '/Vis');


    for i = 1:numel(epochIDs)

        % Find the specific file
        iFile = rawFiles(contains(rawFiles, sprintf("%04.0f", epochIDs(i))));
        iFile = iFile(1);
        visFile = strrep(iFile, 'ref', 'vis');
        
        if isfile(fullfile(visFolderName, visFile))
            vIn1 = VideoReader(fullfile(folderName, iFile)); %#ok<*TNMLP> 
            vIn2 = VideoReader(fullfile(visFolderName, visFile));
            fprintf('%s - ref=%u, vis=%u\n', epochIDs(i),...
                vIn1.NumFrames, vIn2.NumFrames);
        end
    end
end