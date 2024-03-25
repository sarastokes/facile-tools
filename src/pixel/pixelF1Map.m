function [F1map, h] = pixelF1Map(dataset, epochIDs, varargin)



    ip = inputParser();
    addParameter(ip, 'LED', 4, @isnumeric);
    addParameter(ip, 'SavePath', [], @isfolder);
    parse(ip, varargin{:});


    imStack = dataset.getEpochStackAverage(epochIDs);

    [x, y, t] = size(imStack);
    imStack = reshape(imStack, [x*y, t]);

    avgCycle= cycleAverageFromSquareStim(...
        imStack, dataset.frameTables(epochIDs(1)),...
        "LED", ip.Results.LED, varargin{:});
    T = roiF1F2(avgCycle);

    F1map = reshape(T.F1, x, y, []);

    figure();
    h = imagesc(F1map);
    axis equal tight off;
    colormap('gray');

    cData = h.CData;
    if ~isempty(ip.Results.SavePath)
        if numel(epochIDs) > 1
            str = strjoin(num2str(epochIDs), '_');
        else
            str = num2str(epochIDs);
        end
        imwrite(...
            uint8(255 * cData/max(abs(cData), [], "all")),...
            fullfile(savePath, sprintf('%s_F1b.png', str)));
    end