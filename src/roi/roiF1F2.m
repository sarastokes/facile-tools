function T = roiF1F2(avgCycle)
    % ROIF1F2
    %
    % History:
    %   15Apr2022 - SSP
    % ---------------------------------------------------------------------

    F0 = zeros(size(avgCycle,1),1);
    F1 = zeros(size(F0));
    F2 = zeros(size(F0));
    P1 = zeros(size(F0));
    P2 = zeros(size(F0));
    for i = 1:size(avgCycle,1)
        ft = fft(avgCycle(i,:));
        F0(i) = abs(ft(1)) / size(avgCycle,2) * 2;
        F1(i) = abs(ft(2)) / size(avgCycle,2) * 2;
        F2(i) = abs(ft(3)) / size(avgCycle,2) * 2;
        P1(i) = rad2deg(angle(ft(2)));
        P2(i) = rad2deg(angle(ft(3)));
    end

    ID = rangeCol(1, numel(F1));
    T = table(ID, F0, F1, F2, P1, P2);
