function [GMM, clust1, clust2, axHandles] = classifyLightsOn(dataset, varargin)
% CLASSIFYLIGHTSON
%
% Description:
%   Two approaches for classifying the adapting step responses. 2nd approach
%   is simpler, especially if goal is ON/OFF classification but I haven't
%   fully vetted the outlier and nonresponsive criteria so might need
%   some fine-tuning (think outlier is catching good ROIs).
%
% Syntax:
%   [GMM, clust1, clust2] = classifyLightsOn(dataset)
%   [GMM, clust1, clust2, axH] = classifyLightsOn(data, 'NumComponents', 3)
%
% Inputs:
%   dataset             double (N x T) or Dataset object
% Optional key/value inputs:
%   stimName            string or ao.Stimuli enum
%       Use if dataset is a Dataset object and adapting steps are run for
%       more than 1 light level
%   NumComponents       scalar integer (default = 3)
%       Number of components for GMM model
%   Criterion           string/char (default, "CalinskiHarabasz")
%       Criterion for checking the best number of components. Options are
%       "gap", "silhouette", "CalinskiHarabasz", "DaviesBouldin"
%
% Outputs:
%   GMM                 GaussianMixModel object
%   clust1              (N x 1) Cluster indices from GMM
%   clust2              (N x 1) Cluster indices from alternative approach
%   axHandles           (1 x 3) Axes handles for 3 plots created
%
% History:
%   20Mar2024 - SSP
%   25Mar2024 - SSP - better plotting
% -------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'StimName', [], @istext);
    addParameter(ip, 'NumComponents', 3, @isnumeric);
    parse(ip, varargin{:});

    if isempty(ip.Results.StimName) && ~isnumeric(dataset)
        stimNames = string(dataset.stim.Stimulus);
        stimName = stimNames(contains(stimNames, "LightsOn"));
        if numel(stimName) > 1
            error('More than one lights on stimulus found, specify which');
        end
    else
        stimName = ip.Results.StimName;
    end

    if ~isnumeric(dataset)
        signals = dataset.getStimulusResponses(stimName, [250 498], "Smooth", 100, "Average", true);
    else
        signals = mean(dataset, 3);
    end

    [adaptIdx, peakMag] = roiAdaptIndex(signals, [507 100], [350 100], [2 98]);

    GMM = cluster.GaussianMixModel([adaptIdx, peakMag], ip.Results.NumComponents);
    [clust1, ~, ~, clustAxis] = GMM.cluster();

    if ~isnumeric(dataset)
        title(clustAxis, dataset.getLabel(), "Interpreter", "none");
    end
    ylim(clustAxis, [floor(clustAxis.YLim(1)), ceil(clustAxis.YLim(2))]);
    xlim([-1 1]); xlabel('Final:Peak Response (dF/F)');
    ylabel('Peak Response (dF/F)');
    h1 = plot([0 0], clustAxis.YLim, 'k', 'LineWidth', 0.75);
    h2 = plot(clustAxis.XLim, [0 0], 'k', 'LineWidth', 0.75);
    uistack([h1, h2], "bottom"); noLegend([h1, h2]);
    legend(clustAxis, "Location", "northwest");
    grid on; axis square; tightfig(clustAxis.Parent);

    % Check the best number of components with Calinski-Harabasz index
    GMM.checkComponents();
    compAxis = gca;

    % Alternative approach (needs fine-tuning)
    offFcn = @(mag) mag < 0;
    onFcn = @(mag) mag > 0;
    nrFcn = @(adapt, mag) inrange(mag, -0.1, 0.2);
    outlierFcn = @(adapt, mag) (mag < 0 & adapt < 0.35) | (mag>0 & adapt>0.3);

    clust2 = zeros(size(adaptIdx));
    clust2(onFcn(mean(peakMag,2))) = 1;
    clust2(offFcn(mean(peakMag,2))) = 2;
    clust2(outlierFcn(mean(adaptIdx,2), mean(peakMag,2))) = 3;
    clust2(nrFcn(mean(adaptIdx,2), mean(peakMag,2))) = 0;

    ax = axes('Parent', figure()); hold on;
    if ~isnumeric(dataset)
        title(ax, dataset.getLabel(), "Interpreter", "none");
    end
    scatter(adaptIdx(clust2==1), peakMag(clust2==1), 9, hex2rgb('00cc4d'), "filled");
    scatter(adaptIdx(clust2==2), peakMag(clust2==2), 9, hex2rgb('ff4040'), "filled");
    scatter(adaptIdx(clust2==3), peakMag(clust2==3), 9, "b", "filled");
    scatter(adaptIdx(clust2==0), peakMag(clust2==0), 9, [0.3 0.3 0.3], "filled");
    ax.YLim = [floor(ax.YLim(1)), ceil(ax.YLim(2))]; xlim([-1 1]);
    h1 = plot([0 0], ax.YLim, 'k', 'LineWidth', 0.75);
    h2 = plot(ax.XLim, [0 0], 'k', 'LineWidth', 0.75);
    uistack([h1, h2], "bottom"); noLegend([h1, h2]);
    xlabel('Final:Peak Response (dF/F)');
    ylabel('Peak Response (dF/F)');
    grid on; axis square;
    axis square; figPos(gcf, 0.8,0.8); tightfig(gcf);

    axHandles = [clustAxis, compAxis, ax];