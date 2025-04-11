function writeRegisteredAvi(dataset, epochID, savePath)
% WRITEREGISTEREDAVI
%
% Syntax:
%   writeRegisteredAvi(dataset, epochID, savePath)
%
% History:
%   25Sept2024 - SSP
% -------------------------------------------------------------------------

    arguments
        dataset
        epochID     (1,1)    {mustBeInteger}
        savePath    (1,1)   string   = cd
    end

    if nargin < 3
        savePath = string(cd);
    end

    imStack = dataset.getEpochStacks(epochID);
    nFrames = size(imStack, 3);

    v = VideoWriter(fullfile(savePath, sprintf("vis_%04d.avi", epochID)), "Grayscale AVI");
    v.FrameRate = 25;
    open(v);
    % Write each frame
    for i = 1:nFrames
        writeVideo(v, imStack(:,:,i));
    end
    close(v);
