function [f0, fInt, fMotion, motionHz] = signalFftStats(signals)

    [R, ~, N] = size(signals);
    f0 = zeros(R, N);
    fInt = zeros(R, N);
    motionHz = zeros(R, N);
    fMotion = zeros(R, N);
    for i = 1:R
        for j = 1:N
            [p, f] = signalPowerSpectrum(squeeze(signals(i,:,j)), 25);
            % DC
            f0(i,j) = p(1);
            % Area
            fInt(i,j) = sum(p(f < 12.5));
            % Respiration artifact
            idx = find(f > 0.27 & f < 0.3);
            [noisePeak, peakIdx] = max(p(idx));
            motionHz(i,j) = noisePeak;
            fMotion(i,j) = f(idx(peakIdx));
        end
    end