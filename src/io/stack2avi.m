function stack2avi(imStack, videoName)
    % STACK2AVI
    %
    % Syntax:
    %   stack2avi(imStack, videoName)
    %
    % History:
    %   27Oct2022 - SSP
    % ---------------------------------------------------------------------
    if ~endsWith(videoName, '.avi')
        videoName = [videoName, '.avi'];
    end

    v = VideoWriter(videoName, 'Grayscale AVI');
    v.FrameRate = 25;
    open(v);

    for i = 1:size(imStack,3)
        iFrame = squeeze(imStack(:,:,i));
        writeVideo(v, iFrame);
    end
    close(v);
    fprintf('Completed %s\n', videoName);
end