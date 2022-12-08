function [REG, quality, IDs] = batchMonomodalRegistration(imStack, refID, varargin)
    % BATCHMONOMODALREGISTRATION
    %
    % Syntax:
    %   [reg, idx] = batchMonomodalRegistration(imStack, refID, plotFlag)
    %
    % Input:
    %   imStack                 stack of images to register
    %   refID                   index of reference image in stack
    % Optional key/value inputs:
    %   Plot                    whether or not to plot
    %   OmitSkips               whether to omit skipped registrations
    %   IDs                     epochIDs corresponding to each image
    %
    % See also:
    %   runMonomodalRegistration2, registrationEstimator
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Plot', false, @islogical);
    addParameter(ip, 'OmitSkips', false, @islogical);
    addParameter(ip, 'IDs', 1:size(imStack,3), @isnumeric);
    parse(ip, varargin{:});
    
    plotFlag = ip.Results.Plot;
    omitSkips = ip.Results.OmitSkips;
    IDs = ip.Results.IDs;

    % Extract reference from IDs and imStack
    refIdx = find(IDs==refID); disp(refIdx)
    IDs(IDs==refID) = [];
    FIXED = imStack(:,:, refIdx);
    regStack = imStack; regStack(:,:,refIdx) = [];

    REG = []; quality = [];
    for i = 1:(size(regStack, 3))
        fprintf('Registering %u\n\t', IDs(i));
        [S, Q] = runMonomodalRegistration2(squeeze(regStack(:,:,i)), FIXED,...
            'Normalize', false, 'Blur', false, 'Plot', plotFlag);
        if Q.Warning
            fprintf('\t');
            [S, Q] = runMonomodalRegistration2(squeeze(regStack(:,:,i)), FIXED,...
            'Normalize', true, 'Blur', true, 'Plot', plotFlag);
        end
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