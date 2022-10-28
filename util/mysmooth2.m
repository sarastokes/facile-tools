function smoothedData = mysmooth2(data, smoothFac, dim)
    % MYSMOOTH2
    % 
    % Syntax:
    %   smoothedData = mysmooth2(data, smoothFac, dim)
    %
    % See also:
    %   MYSMOOTH, SMOOTH
    %
    % History:
    %   27Oct2021 - SSP
    % -------------------------------------------------------------

    if ~ismatrix(data)
        data = squeeze(data);
        if ~ismatrix(data)
            error('MYSMOOTH2: Data must be 2D');
        end
    end
    
    if nargin < 3
        dim = 2;
    else
        assert(ismember(dim, [1 2]),... 
            'MYSMOOTH2: Dimension must be either 1 or 2!');
    end

    smoothedData = zeros(size(data));

    if dim == 1
        for i = 1:size(data, 2)
            smoothedData(:, i) = mysmooth(data(:, i), smoothFac);
        end
    elseif dim == 2
        for i = 1:size(data, 1)
            smoothedData(i, :) = mysmooth(data(i, :), smoothFac);
        end
    end