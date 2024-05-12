function maxValues = roiUnsignedPeak(signals, pct)

    arguments
        signals
        pct         (1,1)   {mustBeNonnegative} = 0
    end

    if pct > 0
        maxValues = prctile(signals, 100-pct, 2);
        minValues = prctile(signals, pct, 2);
    else
        error('Not yet implemented');
    end

    idx = abs(minValues) > abs(maxValues);
    maxValues(idx) = minValues(idx);

    maxValues = squeeze(maxValues);