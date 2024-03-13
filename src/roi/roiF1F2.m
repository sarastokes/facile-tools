function T = roiF1F2(avgCycle)
% ROIF1F2
%
% Description:
%   Given the average cycle, Get the F1 and F2 amplitude and phase plus F0.
%
% Syntax:
%   T = roiF1F2(avgCycle)
%
% Inputs:
%   avgCycle        double, [N x t]
%       The cycle averaged response with t determined by stim frequency
%
% History:
%   15Apr2022 - SSP
% --------------------------------------------------------------------------

    arguments
        avgCycle    (:,:)       double
    end

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
