function S = iterHyperParameters(data, compRange, ptsRange)
% ITERHYPERPARAMETERS
%
% Description:
%   Iterates over the number of features and number of non-zero points to
%   determine good values for the given dataset
%
% Syntax:
%   [MSE, AIC, BIC, S, h] = iterHyperParameters(data, compRange, ptsRange)
%
% History:
%   08Apr2024 - SSP
% --------------------------------------------------------------------------

    cmap = othercolor("Spectral10", 256);

    nTime = size(data, 2); nNeurons = size(data, 1);
    MSE = zeros(numel(compRange), numel(ptsRange));
    AIC = zeros(size(MSE)); BIC = zeros(size(MSE));
    f = cell(size(MSE)); b = cell(size(MSE)); v = cell(size(MSE));
    totalIter = numel(compRange) * numel(ptsRange);

    progressbar(0)
    counter = 0;
    for i = 1:numel(compRange)
        nComp = compRange(i);
        for j = 1:numel(ptsRange)
            nNonZero = ptsRange(j);
            counter = counter + 1;
            [ff, bb, vv] = testSPCA(data, nComp, nNonZero);%cluster.computeFeatures(data', nComp, nNonZero);
            recon = (bb * ff)';
            % Find the MSE
            squaredError = (data - recon).^2;
            MSE(i,j) = mean(squaredError(:));
            AIC(i,j) = MSE(i,j) + 2 * (nComp * (nNonZero + 1)) / (nNeurons * nTime);
            BIC(i,j) = MSE(i,j) + log(nNeurons * nTime) * (nComp * (nNonZero + 1)) / (nNeurons * nTime);
            % Store the results
            f{i,j} = ff; b{i,j} = bb; v{i,j} = vv;
            progressbar(counter/totalIter);
        end
    end


    [minMSE, minIdx] = matrixMin(MSE);
    S = struct('minMSE', minMSE, "BIC", BIC, "AIC", AIC, "MSE", MSE,...
        'numFeatures', compRange(minIdx(1)), "nNonZero", ptsRange(minIdx(2)), ...
        "ptsRange", ptsRange, "compRange", compRange,...
        "f", f, "b", b, "v", v);

    fh1 = figure('Name', 'MSE');
    h = heatmap(MSE);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", cmap);
    h.Title = "Mean Squared Error";
    h.XLabel = "Number of Points"; h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    fh2 = figure('Name', 'AIC');
    h = heatmap(AIC);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", cmap);
    h.Title = "AIC";
    h.XLabel = "Number of Points"; h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    fh3 = figure('Name', 'BIC');
    h = heatmap(BIC);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", cmap);
    h.Title = "BIC";
    h.XLabel = "Number of Points";
    h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    h = [fh1, fh2, fh3];