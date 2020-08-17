function h = myimagesc(im)
    % MYIMAGESC
    %
    % Description:
    %   Wrapper for imagesc with axis aesthetics

    h = imagesc(im);
    axis equal tight off;
