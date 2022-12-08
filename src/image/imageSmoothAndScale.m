function out = imageSmoothAndScale(im, smoothFac)

    if nargin < 2
        smoothFac = 1;
    end

    im = im2double(im);

    if ismatrix(im)
        [minValue, maxValue] = bounds(im(:));
        out = rescale(imgaussfilt(im, smoothFac), minValue, maxValue);
    else
        out = zeros(size(im));
        maxRGB = max(im, [], 1:2);
        minRGB = min(im, [], 1:2);
        for i = 1:size(im,3)
            out(:,:,i) = rescale(imgaussfilt(im(:,:,i), smoothFac), minRGB(i), maxRGB(i));
        end
    end