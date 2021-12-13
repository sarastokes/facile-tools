function onsetMap = pixelOnsetMap(imStack, stimWindow, bkgdWindow)
    % PIXELONSETMAP
    %
    % Syntax:
    %   [onsetMap, offsetMap] = pixelOnsetOffsetMap(imStack, onsetWindow, bkgdWindow)
    %
    % Inputs:
    %   imStack         video data [x, y, t]
    %   stimWindow      [a b]
    %       where a and b are the first and last frames of the stimulus
    %   bkgdWindow      [a b]
    %       where a and b are the first and last frames preceeding the
    %       stimulus that you want to use to compute the baseline activity
    % ---------------------------------------------------------------------
    imStack = double(imStack);

    bkgdStack = squeeze(mean(imStack(:, :, bkgdWindow(1):bkgdWindow(2)), 3));
    onsetStack = squeeze(mean(imStack(:, :, stimWindow(1):stimWindow(2)), 3));
   
    onsetMap = onsetStack - bkgdStack;
    
    figure(); 
    symMap(onsetMap, 'Sigma', 2);
    
    
    
    