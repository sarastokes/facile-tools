function [tform, imReg, refObj0, QI] = runMonomodalRegistration(im, im0)
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

    % Normalize the images
    finiteIdx = isfinite(im0(:));
    im0(isnan(im0)) = 0;
    im0(im0==Inf) = 1;
    im0(im0==-Inf) = 0;
    minVal = min(im0(:));
    maxVal = max(im0(:));
    if isequal(maxVal, minVal)
        im0 = 0*im0;
    else
        im0(finiteIdx) = (im0(finiteIdx) - minVal) ./ (maxVal - minVal);
    end

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


    refObj = imref2d(size(im));
    refObj0 = imref2d(size(im0));

    % Intensity-based registration
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.GradientMagnitudeTolerance = 1.00000e-04;
    optimizer.MinimumStepLength = 1.00000e-05;
    optimizer.MaximumStepLength = 6.25000e-02;
    optimizer.MaximumIterations = 100;
    optimizer.RelaxationFactor = 0.500000;

    % Align centers
    [x0, y0] = meshgrid(1:size(im0, 2), 1:size(im0,1));
    [x, y] = meshgrid(1:size(im,2), 1:size(im, 1));
    intensitySum0 = sum(im0(:));
    intensitySum = sum(im(:));  
    XCOM0 = (refObj0.PixelExtentInWorldX .* (sum(x0(:).*double(im0(:))) ./ intensitySum0)) + refObj0.XWorldLimits(1);
    YCOM0 = (refObj0.PixelExtentInWorldY .* (sum(y0(:).*double(im0(:))) ./ intensitySum0)) + refObj0.YWorldLimits(1);
    XCOM = (refObj.PixelExtentInWorldX .* (sum(x(:).*double(im(:))) ./ intensitySum)) + refObj.XWorldLimits(1);
    YCOM = (refObj.PixelExtentInWorldY .* (sum(y(:).*double(im(:))) ./ intensitySum)) + refObj.YWorldLimits(1);
    Tx = XCOM0 - XCOM;
    Ty = YCOM0 - YCOM;

    % Coarse alignment
    tformInit = affine2d();
    tformInit.T(3, 1:2) = [Tx, Ty];

    % Apply transform to normalized images
    tform = imregtform(mat2gray(im), refObj, mat2gray(im0), refObj0,...
        'Rigid', optimizer, metric,...
        'PyramidLevels', 3,...
        'InitialTransformation',tformInit);

    imReg = imwarp(im, refObj, tform,... 
        'OutputView', refObj0, 'SmoothEdges', true);

    QI = ssim(im0, imReg);