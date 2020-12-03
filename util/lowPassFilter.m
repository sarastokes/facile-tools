function Xfilt = lowPassFilter(X,F,SampleInterval)
%F is in Hz
%Sample interval is in seconds
%X is a vector or a matrix of row vectors

L = size(X,2);
if L == 1 %flip if given a column vector
    X=X';
    L = size(X,2);
end

FreqStepSize = 1/(SampleInterval * L);
FreqCutoffPts = round(F / FreqStepSize);

% eliminate frequencies beyond cutoff (middle of matrix given fft
% representation)
FFTData = fft(X, [], 2);
FFTData(:,FreqCutoffPts:size(FFTData,2)-FreqCutoffPts) = 0;
Xfilt = real(ifft(FFTData, [], 2));