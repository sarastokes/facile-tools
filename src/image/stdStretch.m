function img = stdStretch(im)
% STDSTRETCH Stretch image using standard deviation
%
% Description:
%   Stretch image using standard deviation, do it for each channel
%   separately, if the channel is not empty.
%
% Syntax:
%   img = stdStretch(im)
%
% Inputs:
%   im          uint8
%       Image to be stretched
%
% Output:
%   img         uint8
%       Stretch the image
%
% History:
%   07Sep2023 - SSP
% -------------------------------------------------------------------------

    arguments
        im          uint8
    end

    if ndims(im) == 3
        img = [];
        for i = 1:size(im, 3)
            if max(im(:,:,i), [], 'all') == 0
                continue
            end
            img = cat(3, img, squeeze(proccess2D(im(:,:,i))));
        end
    else
        img = proccess2D(im);
    end
end

function img = proccess2D(im)
    imd = im2double(im);
    avg = mean2(imd);
    sigma = std2(imd);
    adjRange = [avg-2*sigma, avg+2*sigma];
    if adjRange(1)<0
        adjRange(2) = adjRange(2)-adjRange(1);
        adjRange(1) = 0;
    end
    img = imadjust(im, adjRange, []);
end