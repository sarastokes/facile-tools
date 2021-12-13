function y = roiZScores(x, bkgd)
% ROIZSCORE
%
% Syntax:
%   y = roiZScore(x, bkgd)
%
% Description:
%   Z-score ROI responses
%
% Inputs:
%   x       2D or 3D matrix [N, T, (R)]
%       Where each row is a response to be Z-scored
%   bkgd    [2 x 1]
%       Range of frames for baseline (default = [], uses entire signal)
%
% Outputs:
%   y       2D or 3D matrix [N, T, (R)]     
%       Zscored traces
% 
% History:
%   15Nov2021 - SSP
% -------------------------------------------------------------------------

    if nargin < 2
        bkgd = [];
    end
    
    if ~isa(x, 'double')
        x = im2double(x);
    end

    y = zeros(size(x));

    if ndims(x) == 2  %#ok
        y = getZScore(x, bkgd);
    elseif ndims(x) == 3
        for i = 1:size(x, 3)
            y(:, :, i) = getZScore(x(:, :, i), bkgd);
        end
    end
end

function y = getZScore(x, bkgd)
    y = zeros(size(x));
    if isempty(bkgd)
        for i = 1:size(x, 1)
            y = (x(i,:) - mean(x(i,:))) ./ std(x(i,:));
        end
    else
        for i = 1:size(x, 1)
            y(i, :) = (x(i, :) - mean(x(i, bkgd(1):bkgd(2)))) ./ std(x(i, bkgd(1):bkgd(2)));
        end
    end
end