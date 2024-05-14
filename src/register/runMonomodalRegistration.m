function [MOVINGREG, quality] = runMonomodalRegistration(MOVING, FIXED, varargin)
% RUNMONOMODALREGISTRATION
%
% Description:
%   Monomodal registration with Gaussian blur and normalization
%
% Syntax:
%   MOVINGREG = runMonomodalRegistration2(MOVING, FIXED, varargin)
%
% Input:
%   MOVING                  image to be registered
%   FIXED                   reference image
% Optional key/value inputs:
%   Normalize               whether to apply normalization (false)
%   Blur                    whether to apply Gaussian blur (false)
%   Plot                    whether to plot results (false)
%   RegType                 type of registration ('similarity')
%   AlignType               type of center alignment ('geometric')
%
% Output:
%   MOVINGREG               struct
%       Contains RegisteredImage, SpatialRefObj (imref2d), and
%       Transformation (simtform2d)
%
% Notes:
%   Code based on output of registrationEstimator, with addition of
%   SSIM calculation, warning for failed registration, visualization and
%   greater parameter flexibility
%
% Requirements:
%   ImageProcessingToolbox
%
% See also:
%   batchMonomodalRegistration, ssim, imregtform, imregconfig, imwarp
%
% History:
%   16Nov2022 - SSP
%   15Aug2023 - SSP - Added support for center of mass
%   14May2024 - SSP - Removed im2double conversion which led to failures,
%                     updated to affinetform2d, added maxStepLength param
% ------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Normalize', false, @islogical);
    addParameter(ip, 'Blur', false, @islogical);
    addParameter(ip, 'Plot', false, @islogical);
    addParameter(ip, 'RegType', 'similarity',...
        @(x) ismember(lower(x), ["rigid", "similarity", "affine"]));
    addParameter(ip, 'AlignType', "geometric",...
        @(x) ismember(lower(x), ["geometric", "center of mass"]));
    addParameter(ip, 'MaxStepLength', 0.0312, @isnumeric); % 0.0625
    parse(ip, varargin{:});

    blurFlag = ip.Results.Blur;
    normFlag = ip.Results.Normalize;
    plotFlag = ip.Results.Plot;
    REG_TYPE = lower(ip.Results.RegType);
    ALIGN_TYPE = lower(ip.Results.AlignType);
    maxStepLength = ip.Results.MaxStepLength;

    % Default spatial referencing objects
    fixedRefObj = imref2d(size(FIXED));
    movingRefObj = imref2d(size(MOVING));

    % Intensity-based registration
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.GradientMagnitudeTolerance = 1.00000e-04;
    optimizer.MinimumStepLength = 1.00000e-05;
    optimizer.MaximumStepLength = maxStepLength;
    optimizer.MaximumIterations = 100;
    optimizer.RelaxationFactor = 0.500000;

    % Align centers
    if strcmp(ALIGN_TYPE, 'center of mass')
        [xFixed, yFixed] = meshgrid(1:size(FIXED,2), 1:size(FIXED, 1));
        [xMoving, yMoving] = meshgrid(1:size(MOVING,2), 1:size(MOVING,1));
        sumFixedIntensity = sum(FIXED(:));
        sumMovingIntensity = sum(MOVING(:));
        fixedCenterXWorld = (fixedRefObj.PixelExtentInWorldX .* ...
            (sum(xFixed(:).*FIXED(:)) ./ sumFixedIntensity)) + fixedRefObj.XWorldLimits(1);
        fixedCenterYWorld = (fixedRefObj.PixelExtentInWorldY .* ...
            (sum(yFixed(:).*FIXED(:)) ./ sumFixedIntensity)) + fixedRefObj.YWorldLimits(1);
        movingCenterXWorld = (movingRefObj.PixelExtentInWorldX .* ...
            (sum(xMoving(:).*MOVING(:)) ./ sumMovingIntensity)) + movingRefObj.XWorldLimits(1);
        movingCenterYWorld = (movingRefObj.PixelExtentInWorldY .* ...
            (sum(yMoving(:).*MOVING(:)) ./ sumMovingIntensity)) + movingRefObj.YWorldLimits(1);
    elseif strcmp(ALIGN_TYPE, 'geometric')
        fixedCenterXWorld = mean(fixedRefObj.XWorldLimits);
        fixedCenterYWorld = mean(fixedRefObj.YWorldLimits);
        movingCenterXWorld = mean(movingRefObj.XWorldLimits);
        movingCenterYWorld = mean(movingRefObj.YWorldLimits);
    end
    translationX = fixedCenterXWorld - movingCenterXWorld;
    translationY = fixedCenterYWorld - movingCenterYWorld;

    % Coarse alignment
    %initTform = affine2d();
    %initTform.T(3,1:2) = [translationX, translationY];
    initTform = affinetform2d();
    initTform.A(1:2,3) = [translationX ; translationY];

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
        REG_TYPE, optimizer, metric,...
        'PyramidLevels', 3, 'InitialTransformation', initTform);
    MOVINGREG.Transformation = tform;
    MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform,...
        'OutputView', fixedRefObj, 'SmoothEdges', true);

    % Store spatial referencing object
    MOVINGREG.SpatialRefObj = fixedRefObj;

    % Plot, if necessary
    if plotFlag
        figure(); imshowpair(FIXED, MOVINGREG.RegisteredImage);
    end

    % Report out the improvement in SSIM
    originalSSIM = ssim(FIXED, MOVING);
    newSSIM = ssim(FIXED, MOVINGREG.RegisteredImage);
    quality = struct('OldSSIM', originalSSIM, 'NewSSIM', newSSIM);
    if newSSIM < originalSSIM
        fprintf('WARNING!!! ');     % Registration failed
        quality.Warning = true;
    else
        quality.Warning = false;
    end
    fprintf('SSIM changed from %.3f to %.3f\n', originalSSIM, newSSIM);
