function [imNew, tform] = processPointPairs(movingImage, fixedImage, varargin)
    % PROCESSPOINTPAIRS
    %
    % Syntax:
    %   [imNew, tform] = processPointPairs(movingImage, fixedImage, varargin)
    %
    % History:
    %   19Dec2021 - SSP

    if ~ismatrix(movingImage)
        movingImage = rgb2gray(movingImage);
    end

    if ~ismatrix(fixedImage)
        fixedImage = rgb2gray(fixedImage);
    end

    if nargin == 3 && isstruct(varargin{1})
        [movingPoints, fixedPoints] = cpstruct2pairs(varargin{1});
    end

    if nargin == 4
        movingPoints = varargin{3};
        fixedPoints = varargin{4};
    end

    tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
    imNew = imwarp(movingImage, tform,...
        'OutputView', imref2d(size(fixedImage)));
    
