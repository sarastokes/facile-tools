function [MSE, AIC, BIC, S, h] = iterHyperParameters(data, compRange, ptsRange)

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
            fprintf('%u - %u %u\n', counter, nComp, nNonZero);
            counter = counter + 1;
            [ff, bb, ~] = cluster.computeFeatures(data', nComp, nNonZero);
            recon = (bb * ff)';
            % Find the MSE
            squaredError = (data - recon).^2;
            MSE(i,j) = mean(squaredError(:));
            AIC(i,j) = MSE(i,j) + 2 * (nComp * (nNonZero + 1)) / (nNeurons * nTime);
            BIC(i,j) = MSE(i,j) + log(nNeurons * nTime) * (nComp * (nNonZero + 1)) / (nNeurons * nTime);
            progressbar(counter/totalIter);
        end
    end


    [minMSE, minIdx] = matrixMin(MSE);
    S = struct('minMSE', minMSE, "BIC", BIC, "AIC", AIC, "MSE", MSE,...
        'numFeatures', compRange(minIdx(1)), "nNonZero", ptsRange(minIdx(2)), ...
        "ptsRange", ptsRange, "compRange", compRange); 

    fh1 = figure();
    h = heatmap(MSE);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", slanCM('dense', 256));
    h.Title = "Mean Squared Error";
    h.XLabel = "Number of Points"; h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    fh2 = figure(); h = heatmap(AIC);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", slanCM('dense', 256));
    h.Title = "AIC";
    h.XLabel = "Number of Points"; h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    fh3 = figure(); h = heatmap(BIC);
    set(h, "XData", ptsRange, "YData", compRange, ...
        "FontName", get(0, "DefaultAxesFontName"),...
        "CellLabelFormat", "%.3f",...
        "Colormap", slanCM('dense', 256));
    h.Title = "BIC";
    h.XLabel = "Number of Points";
    h.YLabel = "Number of Features";
    figPos(gcf, 1+(0.02*(max([compRange, ptsRange]-10))), ...
                1+(0.02*(max([compRange, ptsRange]-10))));

    h = [fh1, fh2, fh3];