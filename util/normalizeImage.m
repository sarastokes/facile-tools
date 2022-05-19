function I = normalizeImage(I)
    % NORMALIZEIMAGE
    %
    % Description:
    %   MATLAB's thorough code for normalizing images
    %
    % Syntax:
    %   I = normalizeImage(I)
    % --------------------------------------------------------------------

    % Get linear indices to finite valued data
    finiteIdx = isfinite(I(:));

    % Replace NaN values with 0
    I(isnan(I)) = 0;

    % Replace Inf values with 1
    I(I==Inf) = 1;

    % Replace -Inf values with 0
    I(I==-Inf) = 0;

    % Normalize input data to range in [0,1].
    Imin = min(I(:));
    Imax = max(I(:));
    if isequal(Imax, Imin)
        I = 0*I;
    else
        I(finiteIdx) = (I(finiteIdx) - Imin) ./ (Imax - Imin);
    end