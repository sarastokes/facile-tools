function output = ms2frame(input, sampleRate)

    input = input / 1000;                   % sec
    output = round(input * sampleRate);      % sample