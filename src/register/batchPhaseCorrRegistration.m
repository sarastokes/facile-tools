function [REG, quality, IDs] = batchPhaseCorrRegistration(imStack, refID, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'TformType', 'similarity', @istext);
    addParameter(ip, 'OmitSkips', false, @islogical);
    addParameter(ip, 'IDs', 1:size(imStack,3), @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    omitSkips = ip.Results.OmitSkips;
    tformType = ip.Results.TformType;
    plotFlag = ip.Results.Plot;
    IDs = ip.Results.IDs;

    assert(numel(IDs) == size(imStack, 3), 'Number of IDs must match number of images');

    % Extract reference from IDs and imStack
    refIdx = find(IDs==refID); disp(refIdx)
    IDs(IDs==refID) = [];
    FIXED = imStack(:,:, refIdx);
    regStack = imStack; regStack(:,:,refIdx) = [];

    REG = []; quality = [];
    for i = 1:size(regStack, 3)
        [S, Q] = runPhaseCorrelation(squeeze(regStack(:,:,i)), FIXED, tformType, plotFlag);
        REG = cat(1, REG, S);
        quality = cat(1, quality, Q);
    end

    badReg = []; noReg = []; skipReg = [];
    for i = 1:numel(quality)
        quality(i).RegFlag = true;
        if quality(i).Warning
            badReg = cat(1, badReg, i);
            % Sometimes registration errors occur when the non-registered
            % images are already very similar. Flag these for registration
            % to be skipped.
            if quality(i).OldSSIM > 0.9
                quality(i).RegFlag = false;
                skipReg = cat(1, skipReg, i);
            end
        end
    end
    if ~isempty(badReg)
        fprintf('Bad registration for: '); disp(IDs(badReg));
    end
    if omitSkips && ~isempty(skipReg)
        fprintf('Skipping registration for: '); disp(IDs(skipReg));
        REG(skipReg) = []; quality(skipReg) = []; IDs(skipReg) = [];
    end