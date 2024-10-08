function [REG, IDs] = batchPhaseCorrRegistration(imStack, refID, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addOptional(ip, 'TformType', 'similarity', @istext);
    addParameter(ip, 'OmitSkips', false, @islogical);
    addParameter(ip, 'IDs', 1:size(imStack,3), @isnumeric);
    addParameter(ip, 'Plot', false, @islogical);
    parse(ip, varargin{:});

    omitSkips = ip.Results.OmitSkips;
    tformType = convertCharsToStrings(ip.Results.TformType);
    plotFlag = ip.Results.Plot;
    IDs = ip.Results.IDs;

    assert(numel(IDs) == size(imStack, 3), 'Number of IDs must match number of images');

    % Extract reference from IDs and imStack
    refIdx = find(IDs==refID); disp(refIdx)
    IDs(IDs==refID) = [];
    FIXED = imStack(:,:, refIdx);
    regStack = imStack; regStack(:,:,refIdx) = [];

    REG = []; badReg = [];
    for i = 1:size(regStack, 3)
        obj = runPhaseCorrelation(squeeze(regStack(:,:,i)), FIXED,...
            tformType, plotFlag);
        obj.setID(IDs(i));
        if obj.SSIM < obj.OldSSIM
            badReg = cat(1, badReg, i);
        end
        REG = cat(1, REG, obj);
    end

    if ~isempty(badReg)
        fprintf('Bad registration for: '); disp(IDs(badReg));
    end
    if omitSkips && ~isempty(skipReg)
        fprintf('Skipping registration for: '); disp(IDs(skipReg));
        REG(skipReg) = []; IDs(skipReg) = [];
    end