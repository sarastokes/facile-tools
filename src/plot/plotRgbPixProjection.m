function im = plotRgbPixProjection(rgbProj, opts)
% Plot 3 PCs as an RGB image with some optional aesthetic adjustments
%
% Syntax:
%   im = plotRgbPixProjection(rgbProj, opts)
%
% History:
%   10Oct2023 - SSP
% -------------------------------------------------------------------------

    arguments
        rgbProj         (:,:,3)     double
        opts.ZeroRange  (1,1)       double = 0
        opts.Adjust     (1,:)       double  = 0
        opts.Order      (1,3)       double  {mustBeInRange(opts.Order, 1, 3)} = [1:3]
        opts.Filter     (1,1)       double  = 0
        opts.Plot       (1,1)       logical = true
        opts.Center     (1,1)       logical = false
    end

    rgbDisp = rgbProj;
    if opts.Center
        for i = 1:3
            rgbDisp(:,:,i) = rgbProj(:,:,i) - mean(rgbProj(:,:,i), "all");
        end
    end
    rgbDisp = (rgbDisp+1)/2;

    if all(opts.Adjust > 0)
        if numel(opts.Adjust) == 1
            opts.Adjust = repmat(opts.Adjust, [1 3]);
        end
        for i = 1:3
            lh = opts.Adjust(i) * max(abs(stretchlim(rgbDisp(:,:,i)) - [0.5 0.5]'));
            rgbDisp(:,:,i) = imadjust(rgbDisp(:,:,i), [0.5-lh, lh+0.5], []);
        end
    end

    if ~isequal(opts.Order, 1:3)
        im = cat(3, rgbDisp(:,:,opts.Order(1)), rgbDisp(:,:,opts.Order(2)), rgbDisp(:,:,opts.Order(3)));
    else
        im = rgbDisp;
    end


    if opts.Filter > 0
        im = imgaussfilt(im, opts.Filter);
    end

    if opts.ZeroRange > 0
        im(im > 0.5-opts.ZeroRange & im < 0.5+opts.ZeroRange) = 0.5;
    end

    figure(); imshow(im);
    tightfig(gcf);