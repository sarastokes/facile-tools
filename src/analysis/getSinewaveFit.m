function [beta, sineFit] = getSinewaveFit(avgCycle, temporalFrequency)
    % GETSINEWAVEFIT
    %
    % Syntax:
    %   [beta, sineFit] = getSinewaveFit(avgCycle, temporalFrequency)
    %
    % History:
    % 28Oct2022 - SSP
    % ---------------------------------------------------------------------
    t = 0:(numel(avgCycle)-1);
    t = t * (1/temporalFrequency);

    modelFun = @(b,t)(b(1).*(sin(2*pi*t.*0.15 + b(2))) + b(3)); 
    beta = nlinfit(t, avgCycle, modelFun, [max(avgCycle); 0; 0]);
    
    if nargout == 2
        sineFit = modelFun(beta, t);
    end