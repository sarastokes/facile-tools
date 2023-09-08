function [augImages, augLabels] = augmentImage(image, labels, opts)

    arguments
        image           uint8   {mustBeNumeric}
        labels          uint8   {mustBeNumeric}
        opts.shearRange double  {mustBeLessThanOrEqual(opts.shearRange, 1)} = -0.3:0.05:0.3
        opts.rotRange   double  {mustBeInRange(opts.rotRange, 1, 90)} = 5:5:45
    end

    numImages = 4*(1 + 2*numel(opts.shearRange) + 2*numel(opts.rotRange));
    fprintf('Creating %u images\n', numImages);

    % Preallocate
    n = 4;
    imSize = size(image);
    augImages = zeros(imSize(1), imSize(2), numImages, "uint8");
    augLabels = zeros(imSize(1), imSize(2), numImages, "uint8");

    % Base image and flips
    augImages(:,:,1) = image;
    augLabels(:,:,1) = labels;
    augImages(:,:,2:4) = cat(3, fliplr(image), flipud(image),... 
        fliplr(flipud(image)));
    augLabels(:,:,2:4) = cat(3, fliplr(labels), flipud(labels),...
        fliplr(flipud(labels)));

    % Prep transform inputs
    imSize = size(image);

    for j = 1:4
        iImage = squeeze(augImages(:,:,j));
        iLabel = squeeze(augLabels(:,:,j));
    
        for i = 1:numel(opts.shearRange)
            n = n + 1;
            tform = affinetform2d([1 opts.shearRange(i) 0; 0 1 0; 0 0 1]);
            outputView = affineOutputView(imSize, tform); 
            augImages(:,:,n) = imwarp(iImage, tform, "bilinear", "OutputView", outputView);
            augLabels(:,:,n) = imwarp(iLabel, tform, "nearest", "OutputView", outputView);
        end
        for i = 1:numel(opts.shearRange)
            n = n + 1;
            tform = affinetform2d([1 0 0; opts.shearRange(i) 1 0; 0 0 1]);
            outputView = affineOutputView(imSize, tform); 
            augImages(:,:,n) = imwarp(iImage, tform, "bilinear", "OutputView", outputView);
            augLabels(:,:,n) = imwarp(iLabel, tform, "nearest", "OutputView", outputView);
        end
    
        for i = 1:numel(opts.rotRange)
            n = n + 1;
            augImages(:,:,n) = imrotate(iImage, opts.rotRange(i), "bilinear", "crop");
            augLabels(:,:,n) = imrotate(iLabel, opts.rotRange(i), "nearest", "crop");
        end
        %for i = 1:numel(opts.rotRange)
        %    n = n + 1;
        %    tform = imrotate("Rotation", 360 - opts.rotRange(i), "nearest");
        %    outputView = affineOutputView(imSize, tform); 
        %    augImages(:,:,n) = imwarp(iImage, tform, "OutputView", outputView);
        %    augLabels(:,:,n) = imwarp(iLabel, tform, "OutputView", outputView);
        %end
    end

