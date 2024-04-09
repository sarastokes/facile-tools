function QI = qualityIndex(data)
% QUALITYINDEX
%
% Description:
%   Response quality based on signal-to-noise
%
% Syntax:
%   QI = qualityIndex(data)
%
% Inputs:
%   data           matrix
%       N x T x R (rois by time samples by stimulus repetitions
%
% References:
%   Baden et al (2016) The functional diversity of retinal ganglion
%   cells in mouse retina. Nature, 529, 345-350
%
% History:
%   05Nov2020 - SSP
%   15Dec2020 - SSP - Suppot for multiple ROIs
%   03Apr2024 - SSP - Return NaN when third dimension isn't present
% -------------------------------------------------------------------------

    if ndims(data) < 3
        QI = NaN(size(data,1), 1);
        return
    end

    QI = zeros(size(data, 1), 1);
    for i = 1:size(data, 1)
        y = squeeze(data(i, :, :));
        a = var(mean(y, 2), [], 1);
        b = mean(var(y, [], 1), 2);
        QI(i) = a / b;
    end