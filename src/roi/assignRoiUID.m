function T = assignRoiUID(rois, firstLetter)
    % ASSIGNROIUID
    %
    % Syntax:
    %   T = assignRoiUID(rois, firstLetter)
    %
    % History:
    %   06Mar2022 - SSP
    % ---------------------------------------------------------------------
    
    S = regionprops("table", rois, "Centroid");

    numRois = height(S);
    uids = repmat("", [height(S), 1]);
    T = table(rangeCol(1,height(S)), uids, S.Centroid(:,1), S.Centroid(:,2),...
        'VariableNames', {'ID', 'UID', 'X', 'Y'});
    T = sortrows(T, {'Y', 'X'});

    % There must be an easier way to do this
    alphabet = upper('abcdefghijklmnopqrstuvwxyz');
    for i = 0:(ceil(numRois/26)  - 1)
        for j = 1:26
            iRoi = 26*i + j;
            if iRoi > numRois
                continue
            end
            if isempty(firstLetter)
                A1 = alphabet(ceil(iRoi/(26*26)));
            else
                A1 = firstLetter;
            end
            T.UID(iRoi) = sprintf("%s%s%s", ...
                A1, ... 
                alphabet(i+1), alphabet(j));
        end        
    end

    T = sortrows(T, 'ID');
    T.X = []; T.Y = [];

    if ~isempty(firstLetter)
        secondLetterIdx = 0;
        for i = 0:(ceil(height(T)/26)  - 1)
            secondLetterIdx = secondLetterIdx + 1;
            for j = 1:26
                T.UID((i*26)+j) = sprintf('%s%s%s',...
                    firstLetter, alphabet(secondLetterIdx), alphabet(j));
            end
        end
    end
    %    for i = 1:26
    %        T{i,"UID"} = sprintf('%s%s%s', firstLetter, alphabet(i+1)
end 