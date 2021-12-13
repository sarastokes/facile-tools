function h = myimagesc(im, varargin)
    % MYIMAGESC
    %
    % Description:
    %   Wrapper for imagesc with axis aesthetics
    % ---------------------------------------------------------------------

    h = imagesc(im);
    axis equal tight off;
