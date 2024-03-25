function R = roiCorrCompare(data1, data2, opts)
% ROICORRCOMPARE
%
% Description:
%   Calculate correlation coefficient between ROI responses to two stimuli.
%   Optional normalization and specification of a time region of interest.
%
% Syntax:
%   R = roiCorrCompare(data1, data2)
%   R = roiCorrCompare(data1, data2, 'Bkgd', [250 498], 'Window', [500 750])
%
% History:
%   01Mar2024 - SSP
% --------------------------------------------------------------------------

    arguments
        data1                   double
        data2                   double
        opts.Bkgd       (1,2)   double      = [0 0]
        opts.Window     (1,2)   double      = [0 0]
        opts.Norm       (1,1)   logical     = false
    end

    assert(size(data1, 1) == size(data2, 1),...
        'Data must have the same number of rows (ROIs)');

    if ~isequal(opts.Bkgd, [0 0])
        data1 = roiNormAvg(data1, opts.Bkgd);
        data2 = roiNormAvg(data2, opts.Bkgd);
    elseif opts.Norm
        data1 = roiNormPercentile(data1, 2);
        data2 = roiNormPercentile(data2, 2);
    else % Ensure repeats get averaged
        if ndims(data1) == 3
            data1 = mean(data1, 3);
        end
        if ndims(data2) == 3
            data2 = mean(data2, 3);
        end
    end

    if ~isequal(opts.Window, [0 0])
        if opts.Window(2) == 0
            opts.Window(2) = min([size(data1,2), size(data2,2)]);
        end
        data1 = data1(:, opts.Window(1):opts.Window(2));
        data2 = data2(:, opts.Window(1):opts.Window(2));
    end

    R = zeros(size(data1, 1), 1);
    for i = 1:numel(R)
        iR = corrcoef(data1(i,:), data2(i,:));
        R(i) = iR(1,2);
    end

    printStat(R);


