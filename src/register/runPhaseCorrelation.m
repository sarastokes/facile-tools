function [imReg, tform, S] = runPhaseCorrelation(im1, im2)
    % RUNPHASECORRELATION
    %  
    % Syntax:
    %   [imReg, tform, S] = runPhaseCorrelation(im1, im2)
    %
    % Description:
    %   Register im2 to im1 with phase correlation
    %
    % History:
    %   28Feb2021 - SSP
    %-----------------------------------------------------------

    im1 = normalizeImage(im1);
    im2 = normalizeImage(im2);

    % Default spatial referencing objects
    refObj1 = imref2d(size(im1));
    refObj2 = imref2d(size(im2));

    % Phase correlation
    tform = imregcorr(im2, refObj2, im1, refObj1,...
        'TransformType', 'translation',...
        'Window', true);
    S.Transformation = tform;
    S.RegisteredImage = imwarp(im2, refObj2, tform,... 
        'OutputView', refObj1,... 
        'SmoothEdges', true);

    % Nonrigid registration
    [S.DisplacementField, S.RegisteredImage] = imregdemons(...
        S.RegisteredImage, im1, 100,...
        'AccumulatedFieldSmoothing', 1.0,... 
        'PyramidLevels', 3);

    % Store spatial referencing object
    S.SpatialRefObj = refObj1;
    
    imReg = S.RegisteredImage;
