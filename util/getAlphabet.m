function out = getAlphabet(upperCase)

    if nargin < 2
        upperCase = true;
    end

    out = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", ...
           "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",...
           "Y", "Z"];

    if ~upperCase
        out = lower(out);
    end