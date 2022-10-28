function createStimulusFile(stimFile, stimName, sizing, nFrames, mustang, stimVideo, bkgdVideo)
    % CREATESTIMULUSFILE
    %
    % Syntax:
    %   createStimulusFile(stimFile, sizing, nFrames, mustang, stimVideo, bkgdVideo)
    %
    % Inputs:
    %   stimFile        char
    %       File path and name to save stimulus file as
    %   sizing          numeric [1 x 4]
    %       Imaging window location
    %   nFrames         numeric
    %       Number of frames in stimulus
    %   mustang         numeric 
    %       % intensity of Mustang laser (0-100)
    %   stimVideo
    %       Full file path and name of stimulus video
    %   bkgdVideo       char
    %       Full file path and name of background video
    %
    % History:
    %   13Dec2021 - SSP

    videoPath = 'F:\\FunctionalImaging\\ExperimentParameters\\Stimulation_videos\\';

    if ~endsWith(stimFile, '.txt')
        stimFile = [stimFile, '.txt'];
    end

    fid = fopen(stimFile, 'w');

    fprintf(fid, '[Input]\r\n');

    fprintf(fid, makeLabel('1-phototoxicity, 2-physiology, 3-psychophysics, 4-functional imaging'));
    fprintf(fid, 'Functionality=2\r\n');

    fprintf(fid, makeLabel('file name of the stimulus video for physiology'));
    fprintf(fid, ['StimulusVideoName=', videoPath, stimVideo, '\r\n']);

    fprintf(fid, makeLabel('file name of the background video for physiology'));
    fprintf(fid, ['StimBackVideoName=', videoPath, bkgdVideo, '\r\n']);

    fprintf(fid, makeLabel('imaging window for excitation. offset x, in sinusoidal space'));
    fprintf(fid, ['ImagingWindowX=', num2str(sizing(1)), '\r\n']);

    fprintf(fid, makeLabel('imaging window for excitation. offset y, in sinusoidal space'));
    fprintf(fid, ['ImagingWindowY=', num2str(sizing(2)), '\r\n']);

    fprintf(fid, makeLabel('imaging window for excitation. width, in sinusoidal space'));
    fprintf(fid, ['ImagingWindowDX=', num2str(sizing(3)), '\r\n']);

    fprintf(fid, makeLabel('imaging window for excitation. height, in sinusoidal space'));
    fprintf(fid, ['ImagingWindowDY=', num2str(sizing(4)), '\r\n']);

    fprintf(fid, makeLabel('recording delay after the button "run trial" is clicked, in frames'));
    fprintf(fid, 'StimulationDelay=0\r\n');

    fprintf(fid, makeLabel('# of frames to record after the button "run trial" is clicked'));
    fprintf(fid, ['RecordingDuration=', num2str(nFrames), '\r\n']);

    fprintf(fid, makeLabel('AOM lookup table 1,  for the 488nm laser, percentage in & percentage out'));
    fprintf(fid, 'AOM_LUT1=\r\n');

    fprintf(fid, makeLabel('AOM lookup table 2,  for the topica laser, percentage in & percentage out'));
    fprintf(fid, 'AOM_LUT2=\r\n');

    fprintf(fid, makeLabel('AOM lookup table 3,  for brimrose AOM, percentage in & percentage out'));
    fprintf(fid, 'AOM_LUT3=\r\n');

    fprintf(fid, makeLabel('AOM value for the Mustang 488nm laser, in percentage'));
    fprintf(fid, ['AOM_VALUE1=', num2str(mustang), '\r\n']);

    fprintf(fid, makeLabel('AOM value for brimrose AOM, in percentage, NOT USED YET!!!!'));
    fprintf(fid, 'AOM_VALUE2=0\r\n');

    fprintf(fid, makeLabel('AOM value for the Topica laser, in percentage'));
    fprintf(fid, 'AOM_VALUE3=100\r\n');

    fclose(fid);

end

function out = makeLabel(str)
    breaker = '                          ; ';
    out = [breaker, str, '\n'];
end