function T = roiAssignQuadrantUID(rois, removeExtraCols)
    % ROIASSIGNQUADRANTUID
    % 
    % Syntax:
    %   T = roiAssignQuadrantUID(rois, removeExtraCols)
    %
    % History:
    %   10Mar2022 - SSP
    %   20Mar2022 - SSP - Fixed xy flip, output matches roiUIDs property
    % ---------------------------------------------------------------------

    if nargin < 2
        removeExtraCols = true;
    end

    [x, y] = size(rois);
    S = regionprops("table", rois, "Centroid");

    uids = repmat("", [height(S), 1]);
    T = table(rangeCol(1, height(S)), uids, S.Centroid(:,1), S.Centroid(:,2),...
        'VariableNames', {'ID', 'UID', 'X', 'Y'});
    T.Quadrant = zeros(height(T),1);
    T{T.X <= (y/2) & T.Y <= (x/2), 'Quadrant'} = 1;
    T{T.X > (y/2) & T.Y <= (x/2), 'Quadrant'} = 2;
    T{T.X <= (y/2) & T.Y > (x/2), 'Quadrant'} = 3;
    T{T.X > (y/2) & T.Y > (x/2), 'Quadrant'} = 4;

    T = sortrows(T, {'Quadrant', 'Y', 'X'});

    alphabet = 'abcdefghijklmnopqrstuvwxyz';

    for q = 1:4
        quadrantRois = find(T.Quadrant == q);
        for i = 0:(ceil(numel(quadrantRois)/26) - 1)
            for j = 1:26
                idx = 26*i + j;
                if idx > numel(quadrantRois)
                    continue
                end
                iRoi = quadrantRois(idx);
                T.UID(iRoi) = sprintf("%s%s%s",...
                    alphabet(q), alphabet(i+1), alphabet(j));
            end
        end
    end

    T = sortrows(T, 'ID');
    
    if removeExtraCols
        T.X = []; T.Y = []; T.Quadrant = [];
    end