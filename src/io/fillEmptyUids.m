function fillEmptyUids(dataset, prefixLetter)

    arguments
        dataset
        prefixLetter        (1,1)   string      
    end

    ABC = getAlphabet();
    prefixLetter = upper(prefixLetter);
    mustBeMember(prefixLetter,  ABC);
    getSecondLetter = @(x) ABC(floor((x-1)/26)+1);
    getThirdLetter = @(x) ABC(mod(x-1, 26)+1);
    getFullUid = @(x) prefixLetter + getSecondLetter(x) + getThirdLetter(x);


    emptyUIDs = find(dataset.roiUIDs.UID == "");
    fprintf('Filling %u empty UIDs\n', numel(emptyUIDs));
    counter = 1;
    for i = 1:numel(emptyUIDs)
        iUid = getFullUid(counter);
        while ismember(iUid, dataset.roiUIDs.UID)
            counter = counter + 1;
            iUid = getFullUid(counter);
        end
        dataset.addRoiUID(emptyUIDs(i), iUid);
        counter = counter + 1;
    end
