function R = roiCorrCompare(data1, data2, opts)
% ROICORRCOMPARE
%
% Description:
%   Calculate correlation coefficient between ROI responses to two stimuli.
%   Optional normalization and specification of a time region of interest.
%
% Syntax:
%   R = roiCorrCompare(data1, data2)
%   R = roiCorrCompare(data1, data2, 'Window', [500 750])
%
% Optional key-value inputs:
%   Norm            logical (default = false)
%       Normalize the responses using roiNormPercentile (2nd percentile)
%   Window          double (default = [0 0])
%       Time window of interest for correlation calculation, by default the
%       entire response is used for the calculation.
%
% See also:
%   roiNormPercentile, roiNormAvg, printStat
%
% History:
%   01Mar2024 - SSP
%   24Mar2024 - SSP - limit verbose output to data with >1 ROI
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

    if opts.Norm
        data1 = roiNormPercentile(data1, 2);
        data2 = roiNormPercentile(data2, 2);
    end

    % Ensure repeats get averaged
    if ndims(data1) == 3
        data1 = mean(data1, 3);
    end
    if ndims(data2) == 3
        data2 = mean(data2, 3);
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

    if numel(R) > 1
        printStat(R);
    end

