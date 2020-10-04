function [imReg, scale, theta] = runPlotSURF(im1, im2, method)
    % RUNPLOTSURF
    %
    % Description:
    %   Register im2 to im1 with SURF
    %
    % Syntax:
    %   [imReg, scale, theta] = runPlotSURF(im1, im2)
    %
    % See also: 
    %   DETECTSURFFEATURES
    % 
    % History:
    %   14Aug2020 - SSP
    % --------------------------------------------------------------------

    if nargin < 3
        method = 'similarity';
    end
    
    ptsOne = detectSURFFeatures(im1);
    ptsTwo = detectSURFFeatures(im2);

    % Identify features in each image
    [featuresOne, validPtsOne] = extractFeatures(im1, ptsOne);
    [featuresTwo, validPtsTwo] = extractFeatures(im2, ptsTwo);

    % Match features between two images
    indexPairs = matchFeatures(featuresOne, featuresTwo);

    matchedOne = validPtsOne(indexPairs(:, 1));
    matchedTwo = validPtsTwo(indexPairs(:, 2));

    % Remove outliers
    [tform, inlierTwo, inlierOne] = estimateGeometricTransform(...
        matchedTwo, matchedOne, method);

    % Plot
    figure();
    showMatchedFeatures(im1, im2, inlierOne, inlierTwo);

    % Solve for transform
    c1 = tform.invert.T(2, 1);
    c2 = tform.invert.T(1, 1);

    scale = sqrt(c1*c1 + c2*c2);
    theta = atan2(c1, c2) * 180/pi;

    % Register image
    outputView = imref2d(size(im1));
    imReg = imwarp(im2, tform, 'OutputView', outputView);

    figure(); imshowpair(im1, imReg);
    