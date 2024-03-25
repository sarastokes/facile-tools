function plotWaterfallResponses(data, xpts)

    arguments
        data        (:,:)   double
        xpts        (1,:)   double  = 1:size(data,2)
    end

    figure(); hold on;
    colororder("glow12");
    runningOffset = 0;
    for i = 1:size(data)
        if i > 1
            runningOffset = runningOffset + min(data(i,:));
        end
        plot(xpts, data(i,:)+runningOffset, 'LineWidth', 1);
        runningOffset = runningOffset + max(data(i,:));
    end

    figPos(gcf, 0.7, 1 + 0.05*size(data,1));
