function roiUIDs = makeNewRoiUIDs(roiUIDs, firstLetter)
    % MAKENEWROIUIDS
    %
    % Syntax:
    %   T = makeNewRoiUIDs(roiUIDs, firstLetter)
    %
    % History:
    %   15Jun2022 - SSP
    % ---------------------------------------------------------------------

    if isstring(firstLetter)
        firstLetter = char(firstLetter);
    end
    firstLetter = upper(firstLetter);

    alphabet = upper('abcdefghijklmnopqrstuvwxyz');

    emptyUIDs = find(roiUIDs.UID == "");
    for i = 1:numel(emptyUIDs)
        idx2 = ceil(i/26);
        idx3 = i - (26*(idx2-1));
        secondLetter = alphabet(idx2);
        thirdLetter = alphabet(idx3);
        roiUIDs.UID(emptyUIDs(i)) = string([firstLetter, secondLetter, thirdLetter]);
    end

