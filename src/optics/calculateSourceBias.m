function B = calculateSourceBias(pupilSize)

    pupilSize = pupilSize/1000;  % mm to m

    dLCA_488_800 = 1.319;
    fLens = 60e-3;
    CAlens = 9.8e-3;

    B = (1 / (1/fLens + (pupilSize/CAlens)^2 * dLCA_488_800)) - fLens;

    B = B * 1000; % m to mm