function stimOut = validateStim(stimIn)
    % VALIDATESTIM
    %
    % Description:
    %   Ensures stimulus class, tries to parse if not
    %
    % Syntax:
    %   stimOut = validateStim(stimIn)
    %
    % History:
    %   11May2022 - SSP
    % ---------------------------------------------------------------------

    if isa(stimIn, 'ao.SpectralStimuli') || isa(stimIn, 'ao.Stimuli')
        stimOut = stimIn;
        return
    end

    if isstring(stimIn)
        stimIn = char(stimIn);
    end

    stimOut = ao.SpectralStimuli.init(stimIn);
    if stimOut ~= ao.SpectralStimuli.Other
        return
    end

    stimOut = ao.Stimuli.init(stimIn);
    if stimOut ~= ao.Stimuli.Other
        return
    end

    error('VALIDATESTIM: Invalid stimulus input %s', stimIn);