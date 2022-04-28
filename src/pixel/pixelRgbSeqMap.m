function rgbMap = pixelRgbSeqMap(dataset, epochIDs, varargin)
    % PIXELRGBSEQMAP
    %
    % Syntax:
    %   rgbMap = pixelRgbSeqMap(dataset, epochIDs, varargin)
    %

    % History:
    %   11Mar2022 - SSP
    % ---------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Sigma', [], @isnumeric);
    parse(ip, varargin{:});

    if ischar(epochIDs)
        epochIDs = dataset.stim2epochs(epochIDs);
    end

    imStack = dataset.getEpochStackAverage(epochIDs);

    frameTable = dataset.frameTables(epochIDs(1));
    redUp = getSquareModulationTiming(frameTable, 1, true);
    greenUp = getSquareModulationTiming(frameTable, 2, true);
    blueUp = getSquareModulationTiming(frameTable, 3, true);


    bkgd = mean(imStack(:,:,300:498), 3);
    
    redOnset = mean(imStack(:,:,window2idx(redUp)), 3) - bkgd;
    greenOnset = mean(imStack(:,:,window2idx(greenUp)), 3) - bkgd;
    blueOnset = mean(imStack(:,:,window2idx(blueUp)), 3) - bkgd;

    rgbMap = cat(3, redOnset, greenOnset, blueOnset);
    if ~isempty(ip.Results.Sigma)
        for i = 1:3
            rgbMap(:,:,i) = imgaussfilt(rgbMap(:,:,i), ip.Results.Sigma);
        end
    end
    rgbMap = rgbMap / (max(abs(rgbMap(:))));

    figure(); image(0.5 + (rgbMap / 2));
    title(dataset.getLabel(),... 
        'FontSize', 10, 'FontName', 'Roboto',...
        'Interpreter', 'none');
    axis equal tight off;
    tightfig(gcf);

    titles = {'R','G', 'B'};
    figure(); hold on;
    for i = 1:3
        subplot(1,4,i); hold on;
        imagesc(rgbMap(:,:,i));
        colormap(gray)
        caxis(gca, [-1 1]);
        title(titles{i},... 
            'FontSize', 10, 'FontName', 'Roboto',...
            'Interpreter', 'none');       
        axis equal tight off;
    end
    subplot(1,4,4); hold on;
    image(0.5 + (rgbMap / 2));
    axis equal tight off;
    title(dataset.getLabel(),... 
        'FontSize', 10, 'FontName', 'Roboto',...
        'Interpreter', 'none');   
    figPos(gcf, 1.25, 1); 
    tightfig(gcf);
