function signals = signalNormalize(signals, bkgdWindow)
    % SIGNALNORMALIZE
    %
    % Description:
    %   Normalize to span between 0 and 1
    %
    % Syntax:
    %   signals = signalNormalize(signals, dim)
    %
    % Inputs:
    %   signals             vector or matrix of responses
    %   dim                 dimension(s) to normalize along (default = 2)
    % 
    % History:
    %   02Nov2022 - SSP
    %   04Nov2022 - SSP - better calc but 2nd dim specific
    % ---------------------------------------------------------------------
    if nargin < 2
        bkgd = [];
    else
        bkgd = window2idx(bkgdWindow);
    end
    
    if ndims(signals) == 3
        for i = 1:size(signals, 3)
            signals(:,:,i) = doNorm(squeeze(signals(:,:,i)), bkgd);
        end
    else
        signals = doNorm(signals,bkgd);
    end
end

function signals = doNorm(signals, bkgd)

    for i = 1:size(signals, 1)
        if nnz(isnan(signals(i,:))) > 0
            continue
        end
        signals(i,:) = rescale(signals(i,:));
        if ~isempty(bkgd)
            signals(i,:) = signals(i,:) - mean(signals(i, bkgd), 2);
        end
        %[s, l] = bounds(signals(i,:));
        %signals(i,:) = 1/max(abs([s, l])) * signals(i,:);
    end
end