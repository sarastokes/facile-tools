function newStack = downsampleMean(imStack, N)
% DOWNSAMPLEMEAN
%
% Description:
%   Simpler, quicker alternative to decimate
%
% Syntax:
%   newStack = downsampleMean(imStack, N)
%
% Notes:
%   If imStack is 3D, downsampling occurs along 3rd dimension.
%   If imStack is 2D, downsampling occurs along 2nd dimension.
%
% History:
%   05May2022 - SSP
%   10Oct2023 - SSP - added error and docs
% ---------------------------------------------------------------------

    switch ndims(imStack)
        case 3
            [x, y, t] = size(imStack);
            tNew = floor(t / N);
            newStack = zeros(x, y, tNew);

            for i = 1:tNew
                newStack(:,:,i) = mean(imStack(:,:,N*(i-1)+1:N*i), 3);
            end
        case 2
            [x, t] = size(imStack);
            tNew = floor(t / N);
            newStack = zeros(x, tNew);

            for i = 1:tNew
                newStack(:, i) = mean(imStack(:, N*(i-1)+1:N*i), 2);
            end
        otherwise
            error('Dimensionality must be 2 or 3, not %u', ndims(imStack));
    end