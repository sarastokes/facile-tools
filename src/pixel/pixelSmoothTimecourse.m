function pixelSmoothTimecourse(imStack, sigma)

    for i = 1:size(imStack,1)
        for j = 1:size(imStack, 2)
            imStack(i,j,:) = mysmooth(squeeze(imStack(i,j,:), sigma));
        end
    end