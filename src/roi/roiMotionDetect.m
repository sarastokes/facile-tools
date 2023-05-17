function [idx, values] = roiMotionDetect(signals, varargin)
% ROIMOTIONDETECT
%
% Syntax:
%   idx = roiMotionDetect(signals, varargin)
% 
% Inputs:
%   signals         [N x T]
%       matrix of timecourses
% Optional key/value inputs:
%   cutoff          0.008
%       F1 amplitude cutoff (lower = more lenient)
%   plot            false
%       Whether to plot results
%
% Todo:
%   Make compatible with single repetition data
%
% History:
%   20220401 - SSP
% -------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Cutoff', 0.008, @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    addParameter(ip, 'HighPass', [], @isnumeric);
    addParameter(ip, 'FrameRate', 25.3, @isnumeric);
    parse(ip, varargin{:});
    cutoff = ip.Results.Cutoff;
    plotFlag = ip.Results.Plot;
    highCut = ip.Results.HighPass;
    frameRate = ip.Results.FrameRate;

    maxVals = zeros(size(signals,1), size(signals,3));
    maxPcts = zeros(size(signals,1), size(signals,3));
    for i = 1:size(signals,1)
        for j = 1:size(signals,3)
            if ~isempty(highCut)
                out = signalHighPassFilter(signals(i,:,j), highCut, frameRate);
            else
                out = signals(i,:,j);
            end
            [p,f] = signalPowerSpectrum(out, frameRate);
            maxVals(i,j) = p(findclosest(f, 0.22));
            maxPcts(i,j) = maxVals(i,j)/max(p);
        end
    end
    
    idx = find(islocalmax(mean(maxPcts,2), 'MinProminence', cutoff));
    m = mean(maxPcts,2);
    values = m(idx);
    
    if plotFlag
        figure(); hold on;
        plot(mean(maxPcts,2),'k');
        plot(idx, mean(maxPcts(idx,:),2), 'r*');
        axis tight; grid on;
        xlabel('ROIs');
        title('ROI Motion Detection')
        figPos(gcf, 0.6, 0.6);
    end
    
    fprintf('Found eye motion edge effects in %u of %u ROIs\n',... 
        numel(idx), size(signals,1));    
end
