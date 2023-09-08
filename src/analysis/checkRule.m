function [hits, falsePos, falseNeg] = checkRule(gTruth, idx, value)
    
    if numel(idx) == numel(gTruth)
        predValues = find(idx);
    else
        predValues = idx;
    end
    realValues = find(gTruth == value);
    unknownValues = find(gTruth == 0.5);
    predValues = predValues(~ismember(predValues, unknownValues));

    hits = find(ismember(predValues, realValues));

    falseNeg = setdiff(realValues, predValues);
    falsePos = setdiff(predValues, realValues);

    fprintf('Rule had %u hits, %u false positives and %u false negatives\n',...
        numel(hits), numel(falsePos), numel(falseNeg));
    
    if ~isempty(falsePos)
        fprintf('False positives:'); disp(falsePos')
    end

    if ~isempty(falseNeg)
        fprintf('False negatives:'); disp(falseNeg')
    end