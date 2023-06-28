function imStack2 = rmBkgd(imStack, sz)

    T = size(Y, 3);
    imStack2 = zeros(size(imStack), class(Y));

    for i = 1:nframes
        I = Y(:, :, i);
        tmp = imgaussfilt(I, sz) - I;
        tmp(tmp < 0) = 0;
        Ydcln(:, :, i) = tmp;

        if mod(i, 100) == 0
            disp(['Done #', num2str(i), '/', num2str(nframes)]);
        end

    end
