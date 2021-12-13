function [imReg, tform] = batchRegistration(regFcn, im1, imStack)
    % BATCHREGISTRATION
    %
    % Syntax:
    %   [imReg, tform] = batchRegistration(regFcn, im1, imStack)
    % History:
    %   06Mar2021 - SSP
    %-----------------------------------------------------------

    imReg = zeros(size(imStack)); 
    tform = zeros(3, 3, size(imStack, 3));
    
    for i = 1:size(imStack, 3)
        try
            [imReg(:, :, i), tform(:, :, i)] = regFcn(im1, imStack(:, :, i));
        catch  % Registration didn't work
            tform(:, :, i) = NaN;
        end
    end
