function tforms = readTranslationThenRigid(fName1, fName2)

    [x, y] = readTransformSIFT(fName1);
    tforms = readRigidTransform(fName2);
    tforms(3, 1, :) = squeeze(tforms(3, 1, :)) + x(2:end);
    tforms(3, 2, :) = squeeze(tforms(3, 2, :)) + y(2:end);