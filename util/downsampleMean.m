function newStack = downsampleMean(imStack, N)
    % DOWNSAMPLEMEAN
    %
    % Description:
    %   Simpler, quicker alternative to decimate
    %
    % Syntax:
    %   newStack = downsampleMean(imStack, N)
    %
    % History:
    %   05May2022 - SSP 
    % ---------------------------------------------------------------------
    
    if ndims(imStack) == 3
        [x, y, t] = size(imStack);
        tNew = floor(t / N);
        newStack = zeros(x, y, tNew);

        for i = 1:tNew
            newStack(:,:,i) = mean(imStack(:,:,N*(i-1)+1:N*i), 3);
        end
    elseif ndims(imStack) == 2
        [x, t] = size(imStack);
        tNew = floor(t / N);
        newStack = zeros(x, tNew);

        for i = 1:tNew
            newStack(:, i) = mean(imStack(:, N*(i-1)+1:N*i), 2);
        end
    end