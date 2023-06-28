function out = mynorm(data)

    out = data / max(abs(data(:)));
    