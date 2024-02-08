function degOut = fovConversion(vIn, whichScan)

    if strcmp(whichScan, 'fast')
        degOut = 0.01356*vIn + 0.218;
    else
        % TODO
    end