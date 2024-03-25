function tf = inrange(values, minVal, maxVal, exclusive)

    arguments
        values              {mustBeNumeric}
        minVal      (1,1)   {mustBeNumeric}
        maxVal      (1,1)   {mustBeNumeric, mustBeGreaterThan(maxVal, minVal)}
        exclusive   (1,1)   logical = false
    end
    
    if exclusive
        tf = values > minVal & values < maxVal;
    else
        tf = values >= minVal & values <= maxVal;
    end
