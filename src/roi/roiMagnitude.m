function maxValues = roiMagnitude(signals, frameRange, pct)

    arguments
        signals         double
        frameRange      (1,2)   double = [1 size(signals,2)]
        pct             (1,1)   double = 0
    end

    if pct == 0
        maxValues = max(signals(:,frameRange(1):frameRange(2), :), 2, "omitmissing");
        minValues = min(signals(:,frameRange(1):frameRange(2), :), 2, "omitmissing");
    else
        maxValues = prctile(signals(:,frameRange(1):frameRange(2),:), 100-pct, 2);
        minValues = prctile(signals(:,frameRange(1):frameRange(2),:), pct, 2);
    end 
    
    idx = abs(minValues) > abs(maxValues);
    maxValues(idx) = minValues(idx);
