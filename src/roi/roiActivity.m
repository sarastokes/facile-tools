function signals = roiActivity(imStack, roiMask)
    % ROIACTIVITY
    %
    % Description:
    %   Returns the average response of all pixels within an ROI
    %
    % Syntax:
    %   A = roiActivity(imStack, L)
    %
    % Inputs:
    %   imStack         3D or 4D matrix - [X, Y, T, (R)]
    %       Raw imaging data stack
    %   roiMask         binary 2D matrix [x, Y]
    %       Mask of designating RO
    %
    % Outputs:
    %   signals         2D or 3D matrix - [N, T, R]
    %       Average response over time for each ROI
    %
    % History:
    %   16Nov2021 - SSP - Adapted from roiSignal
    % ---------------------------------------------------------------------
    
    [a, b] = find(roiMask == 1);
    if ndims(imStack) == 3  % [X, Y, T]
        % Time course for each pixel in ROI
        signals = zeros(numel(a), size(imStack, 3));
        for i = 1:numel(a)
            signals(i, :) = imStack(a(i), b(i), :);
        end
        % Average of all pixels in the ROI
        signals = mean(signals, 1);
    elseif ndims(imStack) == 4  % [X, Y, T, R]
        % Time course for each pixel in ROI
        signals = zeros(numel(a), size(imStack, 3));
        for j = 1:size(imStack, 4)
            for i = 1:numel(a)
                signals(i, :, j) = imStack(a(i), b(i), :, j);
            end
        end
        % Average of all pixels in the ROI
        signals = mean(signals, 1);
    end
