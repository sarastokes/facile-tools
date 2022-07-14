function y = getTrace(data, a, b)

    y = squeeze(data(b, a, :));
    y = y';

    