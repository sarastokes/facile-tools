function [fitresult, gof] = fitLightChange(xpts, data, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'XMin', 20, @isnumeric);
    addParameter(ip, 'XMax', max(xpts), @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    plotFlag = ip.Results.Plot;
    xMin = ip.Results.XMin;
    xMax = ip.Results.XMax;


    if isrow(xpts)
        xpts = xpts';
    end
    if isrow(data)
        data = data';
    end

    %ft = fittype('exp2');
    ft = fittype('a*exp(-((x-b).^2)./((heaviside(x-b)*(2*c^2)+(1-heaviside(x-b))*(2*(c^2)*d))))',... 
        'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'final';

    % Excluded points
    excludedPoints = (xpts < xMin) | (xpts > xMax);
    opts.MaxFunEvals = 1000;
    opts.MaxIter = 1000;
    opts.Exclude = excludedPoints;

    % Bounds and starting conditions
    if max(data) > abs(min(data))
        a = prctile(data, 95);
    else
        a = prctile(data, 5);
    end
    [~, idx] = max(data);
    b = (xpts(idx) - 20)/2 + 20;
    opts.StartPoint = [a, b, 3, 0.1];
    opts.Upper = [a+(a*0.3), xMax, Inf, Inf];
    opts.Lower = [a-(a*0.3), xMin, 0, 0];

    [fitresult, gof] = fit(xpts, data, ft, opts);
    fprintf('a=%.2f, b=%.2f, c=%.2f, d=%.2f (r2=%.2f)\n',...
        fitresult.a, fitresult.b, fitresult.c, fitresult.d, gof.rsquare);
    fprintf('\tTime to half-max=%.2f\n', (fitresult.b-20)/2);

    if plotFlag
        figure();
        hold on;
        if xMin > 0
            xregion(0, xMin, 'FaceColor', hex2rgb('ff4040'));
        end
        if xMax < max(xpts)
            xregion(xMax, ceil(max(xpts)), 'FaceColor', hex2rgb('ff4040'));
        end
        plot(xpts, data, 'k', 'LineWidth', 0.75);
        plot(xpts, fitresult(xpts), 'b', 'LineWidth', 2);
        %h = plot(fitresult, xpts, data, excludedPoints);
        grid on;
        figPos(gcf, 0.7, 0.7);
        ylim([floor(min(data)*2)/2, ceil(max(data))]);
        xlim([0, 100]);
    end
