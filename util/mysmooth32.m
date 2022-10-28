function smoothedData = mysmooth32(data, smoothFac)
    % MYSMOOTH32
    %
    % Description:
    %   Smooths along 2nd dimension of 3D dataset
    %
    % Syntax:
    %   smoothedData = mysmooth32(data, smoothFac)
    %
    % See also:
    %   MYSMOOTH, MYSMOOTH2, SMOOTH
    %
    % History:
    %   04Nov2021 - SSP
    % -------------------------------------------------------------

    if ndims(data) ~= 3
        error('MYSMOOTH32: Data must be 3D');
    end
    
    smoothedData = zeros(size(data));
    
    for i = 1:size(data, 3)
        
        smoothedData(:, :, i) = mysmooth2(data(:,:,i), smoothFac);
    end
