function QI = responseQuality(C)
    % RESPONSEQUALITY
    %
    % Description:
    %   Response quality based on signal-to-noise
    %
    % Syntax:
    %   QI = responseQuality(C)
    %
    % Inputs:
    %   C           matrix
    %       T x R (time samples by stimulus repetitions
    %
    % References:
    %   Baden et al (2016) The functional diversity of retinal ganglion
    %   cells in mouse retina. Nature, 529, 345-350
    %
    % History:
    %   05Nov2020 - SSP
    % ---------------------------------------------------------------------
    
    QI = var(mean(C, 2), [], 1) / mean(var(C, [], 1), 2);
    