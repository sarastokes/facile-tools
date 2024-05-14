function [REG, IDs] = batchMonomodalRegistration(imStack, refID, varargin)
% BATCHMONOMODALREGISTRATION
%
% Syntax:
%   [REG, IDs] = batchMonomodalRegistration(imStack, refID, plotFlag)
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
%   runMonomodalRegistration, MonomodalRegistrationResult, ssim, imwarp
%
% History:
%   ??? - SSP
%   12May2024 - SSP - added RegistrationResult support, cleaned code
%   14May2024 - SSP - fixed backup run parameters and added plotting
% --------------------------------------------------------------------------

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'OmitSkips', false, @islogical);
    addParameter(ip, 'IDs', 1:size(imStack,3), @isnumeric);
    parse(ip, varargin{:});

    omitSkips = ip.Results.OmitSkips;
    IDs = ip.Results.IDs;

    assert(numel(IDs) == size(imStack, 3), 'Number of IDs must match number of images');

    % Extract reference from IDs and imStack
    refIdx = find(IDs == refID); disp(refIdx)
    IDs(refIdx) = [];
    FIXED = imStack(:,:, refIdx);
    regStack = imStack; regStack(:,:,refIdx) = [];

    REG = []; badReg = []; skipReg = [];
    for i = 1:(size(regStack, 3))
        fprintf('Registering %u  ', IDs(i));
        [S, Q] = runMonomodalRegistration(squeeze(regStack(:,:,i)), FIXED, ip.Unmatched);
        if Q.Warning
            fprintf('\t');
            [S, Q] = runMonomodalRegistration(squeeze(regStack(:,:,i)), FIXED,...
                'Normalize', false, 'Blur', true);
            % assignin('base', sprintf('imBad_%u', i), regStack(:,:,i));
            % assignin('base', sprintf('imRef_%u', i), FIXED);
        end

        obj = MonomodalRegistrationResult(S, IDs(i), ip.Unmatched);
        obj.setSSIMs(Q.NewSSIM, Q.OldSSIM);
        if Q.NewSSIM < Q.OldSSIM
            badReg = cat(1, badReg, i);
            % Sometimes registration errors occur when the non-registered
            % images are already very similar. Flag these for registration
            % to be skipped.
            if Q.OldSSIM > 0.9
                skipReg = cat(1, skipReg, i);
                obj = MonomodalRegistrationResult(affine2d(eye(3)), IDs(i), ip.Unmatched);
                obj.setSpatialRefObj(FIXED);
                obj.setSSIMs(Q.OldSSIM, Q.OldSSIM);
            end
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

    figure(); hold on;
    plot(IDs, REG.getOldSSIM(), 'Color', 'k', 'Marker', '.', 'MarkerSize', 14);
    plot(IDs, REG.getSSIM(), 'Color', 'b', 'Marker', '.', 'MarkerSize', 14);
    xlabel('Epoch IDs'); ylabel(sprintf('SSIM to Reference (%u)', refID));
    grid on; ylim([0.75, 1]); set(gca, 'YMinorGrid', 'on');
    title('Monomodal Registration (Similarity)');
