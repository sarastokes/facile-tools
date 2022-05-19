function plotBarDataset(signals, ID, varargin)

    signals = squeeze(signals);
    xpts = getX(size(signals,2)+1, 25);
    xpts(1) = [];

    ip = inputParser(); 
    addParameter(ip, 'Ups', [], @isnumeric);
    addParameter(ip, 'Downs', [], @isnumeric);
    addParameter(ip, 'BarOrder', 1:size(signals, 3), @isnumeric);
    addParameter(ip, 'AddScale', false, @islogical);
    parse(ip, varargin{:});

    barOrder = ip.Results.BarOrder;
    ups = ip.Results.Ups;
    downs = ip.Results.Downs;
    addScale = ip.Results.AddScale;

    decProps = {'FaceColor', [0.55, 0.55, 0.55], 'FaceAlpha', 0.4};
    incProps = {'FaceColor', [0.8, 0.8, 0.8], 'FaceAlpha', 0.4};
    traceProps = {'EdgeColor', [0.1 0.1 0.5], 'LineWidth', 1,...
         'FaceAlpha', 1, 'FaceColor', lighten([0.1 0.1 0.5], 0.7)};

    maxVal = (1/3)* ceil(3 * max(abs(signals(ID, :, :)), [], 'all'));
    figure('Name', sprintf('Bars %u', ID));
    for i = 1:size(signals,3)
        barIdx = barOrder(i);
        ax = subplot(1, size(signals, 3), i);
        hold(ax, 'on');

        area(xpts, signals(ID, :, barIdx), ...
            'Tag', sprintf('bar%u', i), traceProps{:});
       
        % setYAxisZScore2(ax, [0.25 0.25], true);
        ylim([-maxVal, maxVal]);
        set(ax, 'YTick', [-maxVal:0.5:maxVal], 'YTickLabel', {});
        setXLimitsAndTicks(floor(0.04*size(signals,2)), 20, ax, true);
        x = ax.XLim;
        ax.XLim = [x(1)+5, x(2)-5];
        addZeroBarIfNeeded(ax);

        if addScale
            addCalibrationBars(ax, 20, 1);
            hideAxes();
        end
                
        if ~isempty(ups)
            addStimPatch(ax, ups, incProps{:});
        end
        if ~isempty(downs)
            addStimPatch(ax, downs, decProps{:});
        end
        reverseChildOrder(ax);
        axis square
    end
    figPos(gcf, 0.8, 0.2);
    tightfig(gcf);