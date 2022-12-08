function [MOVINGREG, quality] = runMonomodalRegistration2(MOVING, FIXED, varargin)
    % RUNMONOMODALREGISTRATION2
    %
    % Description:
    %   Monomodal registration with Gaussian blur and normalization
    %
    % Syntax:
    %   MOVINGREG = runMonomodalRegistration2(MOVING, FIXED, plotFlag)
    %
    % Input:
    %   MOVING                  image to be registered
    %   FIXED                   reference image
    % Optional key/value inputs:
    %   Normalize               whether to apply normalization (false)
    %   Blur                    whether to apply Gaussian blur (false)
    %   Plot                    whether to plot results (false)
    %
    % Output:
    %   MOVINGREG               struct
    %       Contains RegisteredImage, SpatialRefObj (imref2d), and 
    %       Transformation (simtform2d)
    %
    % Notes:
    %   Code based on output of registrationEstimator, with addition of 
    %   SSIM calculation, warning for failed registration and visualization
    %
    % Requirements:
    %   ImageProcessingToolbox
    %
    % See also:
    %   batchMonomodalRegistration
    %
    % History:
    %   16Nov2022 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Normalize', false, @islogical);
    addParameter(ip, 'Blur', false, @islogical);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    blurFlag = ip.Results.Blur;
    normFlag = ip.Results.Normalize;
    plotFlag = ip.Results.Plot;

    % Default spatial referencing objects
    fixedRefObj = imref2d(size(FIXED));
    movingRefObj = imref2d(size(MOVING));

    % Intensity-based registration
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.GradientMagnitudeTolerance = 1.00000e-04;
    optimizer.MinimumStepLength = 1.00000e-05;
    optimizer.MaximumStepLength = 0.0312;       % 7Dec2022
    optimizer.MaximumIterations = 100;
    optimizer.RelaxationFactor = 0.500000;

    % Align centers
    fixedCenterXWorld = mean(fixedRefObj.XWorldLimits);
    fixedCenterYWorld = mean(fixedRefObj.YWorldLimits);
    movingCenterXWorld = mean(movingRefObj.XWorldLimits);
    movingCenterYWorld = mean(movingRefObj.YWorldLimits);
    translationX = fixedCenterXWorld - movingCenterXWorld;
    translationY = fixedCenterYWorld - movingCenterYWorld;

    % Coarse alignment
    initTform = affine2d();
    initTform.T(3,1:2) = [translationX, translationY];

    % Optional processing block
    fixedInit = FIXED;
    movingInit = MOVING;

    % Apply Gaussian blur
    if blurFlag
        fixedInit = imgaussfilt(fixedInit, 1);
        movingInit = imgaussfilt(movingInit, 1);
    end

    % Normalize images
    if normFlag
        movingInit = mat2gray(movingInit);
        fixedInit = mat2gray(fixedInit);
    end

    % Apply transformation
    tform = imregtform(movingInit, movingRefObj, fixedInit, fixedRefObj,...
        'similarity', optimizer, metric,...
        'PyramidLevels', 3, 'InitialTransformation', initTform);
    MOVINGREG.Transformation = tform;
    MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform,... 
        'OutputView', fixedRefObj, 'SmoothEdges', true);

    % Store spatial referencing object
    MOVINGREG.SpatialRefObj = fixedRefObj;

    % Optional plotting
    if plotFlag
        figure(); imshowpair(FIXED, MOVINGREG.RegisteredImage);
    end

    % SSIM report
    originalSSIM = ssim(FIXED, MOVING);
    newSSIM = ssim(FIXED, MOVINGREG.RegisteredImage);
    quality = struct('OldSSIM', originalSSIM, 'NewSSIM', newSSIM);
    if newSSIM < originalSSIM 
        fprintf('WARNING!!! ');     % Registration failed
        quality.Warning = true;
    else
        quality.Warning = false;
    end
    fprintf('SSIM changed from %.2f to %.2f\n', originalSSIM, newSSIM);