function [NL, Rfcn, Gfcn, Bfcn] = getLedNonlinearities(calDate, normFlag)
    % GETLEDNONLINEARITIES
    %
    % Syntax:
    %   [NL, Rfcn, Gfcn, Bfcn] = getLedNonlinearities(calDate, normFlag)
    %
    % History:
    %   24Jan2022 - SSP
    % ---------------------------------------------------------------------
    if nargin < 1 || isempty(calDate)
        calDate = '20220314';
    end

    if nargin < 2
        normFlag = false;
    end

    R = readtable(['LUT_660nm_', calDate, '.txt']);
    G = readtable(['LUT_530nm_', calDate, '.txt']);
    B = readtable(['LUT_420nm_', calDate, '.txt']);

    if normFlag
        R.POWER = R.POWER/max(R.POWER);
        G.POWER = G.POWER/max(G.POWER);
        B.POWER = B.POWER/max(B.POWER);
    end
    NL = table(R.VOLTAGE, R.POWER, G.POWER, B.POWER,...
        'VariableNames', {'V', 'R', 'G', 'B'});

    if nargout > 1
        Rfcn = fit(NL.R, NL.V, 'cubicinterp');
        Gfcn = fit(NL.G, NL.V, 'cubicinterp');
        Bfcn = fit(NL.B, NL.V, 'cubicinterp');
    end