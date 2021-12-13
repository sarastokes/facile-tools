function stim = getModulationLED(stim, ledMean, ledDelta)

    stim = repmat(stim, [3 1]);

    stim = stim .* ledDelta;
    stim = stim + ledMean;

    