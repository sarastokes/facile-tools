function [HFI, Plow, Phigh] = highFrequencyIndex(fwrdChirp, revChirp, stimWindow, opts)
% HIGHFREQUENCYINDEX
%
% Description:
%   An index for the high frequency tuning of a neuron's response to the
%   chirp stimulus. To avoid the influence of the sustained calcium response
%   to the low frequencies, a reverse chirp is used for the high frequency
%   integral and a forward chirp is used for the low frequency integral.
%
% Syntax:
%   [HFI, Plow, Phigh] = highFrequencyIndex(fwrdChirp, revChirp, stimWindow)
%
% Inputs:
%   fwrdChirp           double, [N x T] or [N x T x R]
%       Forward chirp response for N neurons
%   revChirp            double, [N x T] or [N x T x R]
%       Reverse chirp response for N neurons
%   stimWindow          double integer, [1 x 2]
%       The indices of the stimulus start and stop times
% Optional key/value inputs:
%   PlotFlag            logical (default = false)
%       Whether to plot the HFI for the population
%   BkgdWindow          double [1 x 2]
%       The indices of the background window (default = 2nd half of pre-stim)
%   NormFlag            logical (default = false)
%       Whether to normalize the responses
%
% Output:
%   HFI                 double, [N x 1]
%       The high frequency index for each neuron
% Optional outputs:
%   Plow                double, [N x 1]
%       The integral of the low frequency response
%   Phigh               double, [N x 1]
%       The integral of the high frequency response
%
% References:
%   Loosely based on the HFI in Seifert et al (2023) Nature Communications
%
% History:
%   3Jan2023 - SSP
% --------------------------------------------------------------------------

    arguments
        fwrdChirp                   double
        revChirp                    double
        stimWindow          (1,2)   double      {mustBeInteger}
        opts.PlotFlag       (1,1)   logical                      = false
    end

    if ndims(fwrdChirp) == 3
        fwrdChirp = mean(fwrdChirp, 3);
    end

    if ndims(revChirp) == 3
        revChirp = mean(revChirp, 3);
    end

    halfPoint = floor(stimWindow(1) + (stimWindow(2) - stimWindow(1)) / 2);

    Plow = trapz(fwrdChirp(:, stimWindow(1):halfPoint), 2);
    Phigh = trapz(revChirp(:, stimWindow(1):halfPoint), 2);


    HFI = (Phigh - Plow) ./ (Phigh + Plow);

    if opts.PlotFlag
        figure(); hold on;
        h = scatter(1:numel(HFI), HFI, 12, HFI, 'filled');
        set(h, 'MarkerEdgeColor', 'k', 'LineWidth', 0.1);
        addZeroBarIfNeeded(gca); reverseChildOrder(gca);
        colormap(slanCM('thermal-2'));
        xlabel('ROI #'); xlim([1 numel(HFI)]); xticks(0:50:numel(HFI));
        set(gca, 'XMinorTick', 'on');
        ylabel('High Frequency Index'); ylim([floor(min(ylim())), ceil(max(ylim()))]);
        figPos(gcf, 1.25, 0.75);
    end