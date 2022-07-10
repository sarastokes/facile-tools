function [tform, imReg, refObj0, QI] = runMultimodalRegistration(im, im0)
    % MONOMODALREGISTRATION
    %
    % Syntax:
    %   T = monomodalRegistration(im, im0)
    %
    % Description
    %   Registers 'im' to 'im0' with monomodal registration configuration,
    %   rigid transformation, aligned by center of mass and normalized
    % 
    % History:
    %   20211123 - SSP
    % ---------------------------------------------------------------------


    % Normalize images
    finiteIdx = isfinite(im0(:));
    im0(isnan(im0)) = 0;
    im0(im0==Inf) = 1;
    im0(im0==-Inf) = 0;
    minVal = min(im0(:));
    maxVal = max(im0(:));
    if isequal(maxVal,minVal)
        im0 = 0*im0;
    else
        im0(finiteIdx) = (im0(finiteIdx) - minVal) ./ (maxVal - minVal);
    end

    % Normalize MOVING image
    finiteIdx = isfinite(im(:));
    im(isnan(im)) = 0;
    im(im==Inf) = 1;
    im(im==-Inf) = 0;
    minVal = min(im(:));
    maxVal = max(im(:));
    if isequal(maxVal,minVal)
        im = 0*im;
    else
        im(finiteIdx) = (im(finiteIdx) - minVal) ./ (maxVal - minVal);
    end

    % Default spatial referencing objects
    refObj0 = imref2d(size(im0));
    refObj = imref2d(size(im));

    % Intensity-based registration
    [optimizer, metric] = imregconfig('multimodal');
    metric.NumberOfSpatialSamples = 500;
    metric.NumberOfHistogramBins = 50;
    metric.UseAllPixels = false;
    optimizer.GrowthFactor = 1.050000;
    optimizer.Epsilon = 1.50000e-06;
    optimizer.InitialRadius = 6.25000e-03;
    optimizer.MaximumIterations = 100;

    % Align centers
    [x0,y0] = meshgrid(1:size(im,2),1:size(im,1));
    [x,y] = meshgrid(1:size(im,2),1:size(im,1));
    intensitySum0 = sum(im(:));
    intensitySum = sum(im0(:));
    XCOM0 = (refObj0.PixelExtentInWorldX .* (sum(x0(:).*double(im(:))) ./ intensitySum0)) + refObj0.XWorldLimits(1);
    YCOM0 = (refObj0.PixelExtentInWorldY .* (sum(y0(:).*double(im(:))) ./ intensitySum0)) + refObj0.YWorldLimits(1);
    XCOM = (refObj.PixelExtentInWorldX .* (sum(x(:).*double(im0(:))) ./ intensitySum)) + refObj.XWorldLimits(1);
    YCOM = (refObj.PixelExtentInWorldY .* (sum(y(:).*double(im0(:))) ./ intensitySum)) + refObj.YWorldLimits(1);
    translationX = XCOM0 - XCOM;
    translationY = YCOM0 - YCOM;

    % Coarse alignment
    tformInit = affine2d();
    tformInit.T(3,1:2) = [translationX, translationY]; 
    
    % Apply transformation to normalized images
    tform = imregtform(mat2gray(im0),refObj,mat2gray(im),refObj0,...
        'rigid', optimizer, metric,...
        'PyramidLevels',3,'InitialTransformation',tformInit);
    imReg = imwarp(im0, refObj, tform,...
        'OutputView', refObj0, 'SmoothEdges', true);

    QI = ssim(im0, imReg);