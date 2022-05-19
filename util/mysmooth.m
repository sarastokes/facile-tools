function y = mysmooth(y, smoothFac, varargin)
    % MYSMOOTH
    %
    % Description: 
    %   Pads vector before smoothing to avoid edge effects. Smooths along
    %   the second dimension which is assumed to be time.
    %
    % Syntax:
    %   y = mysmooth(y, smoothFac, varargin)
    %
    % Inputs:
    %   y       double, [N x T] or [N x T x R] 
    %       Matrix/vector to smooth along
    %   smoothFac       integer
    %       Smoothing sigma for builtin SMOOTH function
    %   varargin
    %       Additional inputs to builtin SMOOTH function
    %
    % Outputs:
    %   y       input y smoothed along 2nd dimension
    %
    % See also:
    %   SMOOTH
    %
    % History:
    %   11Nov2020 - SSP
    %   11May2022 - SSP - Updated to allow inputs of different sizes
    % ---------------------------------------------------------------------

    if isvector(y)
        if iscolumn(y)
            y = y';
        end
        y = doSmooth(y, smoothFac, varargin{:});
    elseif ndims(y) == 2 %#ok<ISMAT> 
        for i = 1:size(y,1)
            y(i,:) = doSmooth(y(i,:), smoothFac, varargin{:});
        end
    elseif ndims(y) == 3
        for i = 1:size(y,1)
            for j = 1:size(y,3)
                y(i,:,j) = doSmooth(y(i,:,j), smoothFac, varargin{:});
            end
        end
    end
end

function y = doSmooth(y, smoothFac, varargin)
    if size(y, 1) == 1
        padVal = [0, smoothFac];
    elseif size(y, 2) == 1
        padVal = [smoothFac, 0];
    else
        error('Input a vector');
    end

    y = padarray(y, padVal, mean(y), 'both');
    y = smooth(y, smoothFac, varargin);
    y(1:smoothFac) = [];
    y(end-smoothFac+1:end) = [];
end

    
