function T = assignRoiUID(rois)
    % ASSIGNROIUID
    %
    % Syntax:
    %   T = assignRoiUID(rois)
    %
    % History:
    %   06Mar2022 - SSP
    % ---------------------------------------------------------------------
    
    S = regionprops("table", rois, "Centroid");

    numRois = height(S);
    uids = repmat("", [height(S), 1]);
    T = table([1:height(S)]', uids, S.Centroid(:,1), S.Centroid(:,2),...
        'VariableNames', {'ID', 'UID', 'X', 'Y'});
    T = sortrows(T, {'Y', 'X'});

    % There must be an easier way to do this
    alphabet = 'abcdefghijklmnopqrstuvwxyz';
    for i = 0:(ceil(numRois/26)  - 1)
        for j = 1:26
            iRoi = 26*i + j;
            if iRoi > numRois
                continue
            end
            T.UID(iRoi) = sprintf("%s%s%s", ...
                alphabet(ceil(iRoi/(26*26))), ... 
                alphabet(i+1), alphabet(j));
        end        
    end

    T = sortrows(T, 'ID');
    T.X = []; T.Y = [];
end 