function newStack = downsampleSum(imStack, N)

    [x, y, t] = size(imStack);
    tNew = floor(t / N);
    newStack = zeros(x, y, tNew);

    for i = 1:tNew
        newStack(:, :, i) = sum(imStack(:, :, N*(i-1) + 1:N*i), 3);
    end