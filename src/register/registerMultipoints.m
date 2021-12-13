function [fitresult, gof] = registerMultipoints(x, y, startpt)
    % REGISTERMULTIPOINTS
    %
    % [fitresult, gof] = registerMultipoints(x, y, startpt)
    % 
    % History:
    %   07Sep2021 - SSP
    % ---------------------------------------------------------------------

    [xData, yData] = prepareCurveData(x, y);

    ft = fittype('a*x+b',... 
        'Independent', 'x', 'Dependent', 'y');
    opts = fitoptions(...
        'Method', 'NonlinearLeastSquares',...
        'Display', 'off');
    if nargin == 3
        opts.StartPoint = startpt;
    end

    [fitresult, gof] = fit(xData, yData, ft, opts);

