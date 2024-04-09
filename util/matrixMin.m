function [value, idx] = matrixMin(A)

    [values, idx1] = min(A, [], 1);
    [value, idx2] = min(values, [], 2);
    idx = [idx1(2), idx2];