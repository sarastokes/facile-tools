function [R, refResponse] = roiCorrToAvg(data, opts)
% ROICORRTOAVG
%
% Description:
%   Calculate correlation coefficient between each individual ROI response
%   and the mean or median response across all ROIs. Useful for assessing
%   the consistency/reliability of individual responses relative to the
%   group.
%
% Syntax:
%   R = roiCorrToAvg(data)
%   R = roiCorrToAvg(data, 'Method', 'median')
%   [R, refResponse] = roiCorrToAvg(data, 'Window', [500 750])
%
% Inputs:
%   data            double, (N x T) or (N x T x R)
%       ROI responses. If 3D, repeats are averaged before comparison.
%
% Optional key-value inputs:
%   Method          char/string (default = 'mean')
%       Reference response used for comparison, either 'mean' or 'median'
%   Norm            logical (default = false)
%       Normalize the responses using roiNormPercentile (2nd percentile)
%   Window          double (default = [0 0])
%       Time window of interest for correlation calculation, by default the
%       entire response is used for the calculation.
%   LeaveOneOut     logical (default = false)
%       Exclude each ROI from the reference response when computing its own
%       correlation, avoiding inflated correlation from self-comparison.
%   Omit            double (default = [])
%       RoiIDs to omit from mean or median calculation (e.g., motion ROIs)
%
% Outputs:
%   R               double, (N x 1)
%       Correlation coefficient of each ROI to the reference response
%   refResponse     double, (1 x T) or (N x T) if LeaveOneOut is true
%       The reference (mean/median) response(s) used for comparison
%
% See also:
%   roiCorrCompare, roiNormPercentile, printStat
%
% History:
%   20Aug2026 - SSP
% --------------------------------------------------------------------------

    arguments
        data                            double
        opts.Method         (1,1)       string      {mustBeMember(opts.Method, ["mean", "median"])} = "mean"
        opts.Window         (1,2)       double      = [0 0]
        opts.Norm           (1,1)       logical     = false
        opts.LeaveOneOut    (1,1)       logical     = false
        opts.Omit                       double      = []
        opts.RefResponse                double      = []
    end

    % Ensure repeats get averaged
    if ndims(data) == 3
        data = mean(data, 3);
    end

    if opts.Norm
        data = roiNormPercentile(data, 2);
    end

    if ~isequal(opts.Window, [0 0])
        if opts.Window(2) == 0
            opts.Window(2) = size(data, 2);
        end
        data = data(:, opts.Window(1):opts.Window(2));
        if ~isempty(opts.RefResponse)
            opts.RefResponse = opts.RefResponse(opts.Window(1):opts.Window(2));
        end
    end

    N = size(data, 1);
    R = zeros(N, 1);

    if opts.LeaveOneOut && isempty(opts.RefResponse)
        refResponse = zeros(N, size(data, 2));
        for i = 1:N
            idx = true(N, 1);
            idx(i) = false;
            if ~isempty(opts.Omit)
                idx(opts.Omit) = false;
            end
            if opts.Method == "median"
                refResponse(i,:) = median(data(idx,:), 1);
            else
                refResponse(i,:) = mean(data(idx,:), 1);
            end
            iR = corrcoef(data(i,:), refResponse(i,:));
            R(i) = iR(1,2);
        end
    else
        idx = true(N, 1);
        if ~isempty(opts.Omit)
            idx(opts.Omit) = false;
        end
        if ~isempty(opts.RefResponse)
            refResponse = opts.RefResponse;
        elseif opts.Method == "median"
            refResponse = median(data(idx,:), 1);
        else
            refResponse = mean(data(idx,:), 1);
        end
        for i = 1:N
            iR = corrcoef(data(i,:), refResponse);
            R(i) = iR(1,2);
        end
    end

    if numel(R) > 1
        idx = true(N, 1);
        if ~isempty(opts.Omit)
            idx(opts.Omit) = false;
        end
        printStat(R(idx));
    end

end
