classdef SpectralStimuli

    properties (Constant, Hidden)
        LED_RATE = 500;
        FRAME_RATE = 25;

        DEFAULT_AVG_COLOR = [0.1 0.1 0.2];
        INC_PROPS = {'FaceColor', [0.8, 0.8, 0.8], 'FaceAlpha', 0.25};
        DEC_PROPS = {'FaceColor', [0.45, 0.45, 0.45], 'FaceAlpha', 0.4};
    end

    enumeration
        Background
        BackgroundQuarter
        LmsxBackground
        LuminanceBaseline

        Background0p60t
        Background2p60t
        Background5p60t
        Background10p60t
        Background20p60t
        Background25p60t
        Background50p60t

        Background0p110t
        Background10p110t
        Background25p110t

        Background0p120t
        Background5p120t
        Background10p120t

        LconeIncrement20s80t
        LconeDecrement20s80t
        MconeIncrement20s80t
        MconeDecrement20s80t
        SconeIncrement20s80t
        SconeDecrement20s80t
        LMconeIncrement20s80t
        LMconeDecrement20s80t
        
        % 20 second, full contrasts modulations
        LconeSteps110t
        MconeSteps110t
        SconeSteps110t
        LMconeSteps110t
        LuminanceSteps120t
        
        LconeSquare150t
        MconeSquare150t
        SconeSquare150t
        LMconeSquare150t
        IsoluminanceSquare150t
        LuminanceSquare150t

        LconeSquare160t
        MconeSquare160t
        SconeSquare160t
        IsoluminanceSquare160t
        LuminanceSquare160t
        LuminanceSine160t

        LuminanceSquare20s160t
        IsoluminanceSquare20s160t
        SconeSquare20s160t

        LuminanceDecInc20s90t
        LuminanceIncDecInc5p10s80t

        % Different mean levels
        LuminanceSquare5p20s160t
        LuminanceSquare10p20s160t
        SconeSquare5p20s160t
        SconeSquare10p20s160t
        SconeSquare5p10s160t
        SconeSquare10p10s160t

        % 5 second, full contrast modulations
        LuminanceSquare5s50p90t
        IsoluminanceSquare5s50p90t
        % Varying green LED 
        IsoluminanceSquare5s50g50p90t
        IsoluminanceSquare5s100g50p90t
        IsoluminanceSquare5s200g50p90t

        % 120t temporal modulations
        LuminanceSine10hz10p120t

        LuminanceSine1hz25p120t
        LuminanceSine5hz25p120t
        LuminanceSine10hz25p120t
        LuminanceSine15hz25p120t
        LuminanceSine20hz25p120t
        LuminanceSine25hz25p120t
        LuminanceSine30hz25p120t
        LuminanceSine50hz25p120t
        LuminanceSine100hz25p120t

        LuminanceSquare1hz10p120t
        LuminanceSquare5hz10p120t
        LuminanceSquare10hz10p120t
        LuminanceSquare15hz10p120t
        LuminanceSquare20hz10p120t
        LuminanceSquare25hz10p120t
        LuminanceSquare30hz10p120t
        LuminanceSquare50hz10p120t
        LuminanceSquare100hz10p120t

        LuminanceSquare1hz25p120t
        LuminanceSquare5hz25p120t
        LuminanceSquare10hz25p120t
        LuminanceSquare15hz25p120t
        LuminanceSquare20hz25p120t
        LuminanceSquare25hz25p120t
        LuminanceSquare30hz25p120t
        LuminanceSquare50hz25p120t
        LuminanceSquare100hz25p120t
        

        % 160t temporal modulations
        LuminanceSine1hz5p160t
        LuminanceSine5hz5p160t
        LuminanceSine10hz5p160t
        LuminanceSine15hz5p160t
        LuminanceSine20hz5p160t
        LuminanceSine25hz5p160t
        LuminanceSine30hz5p160t
        LuminanceSine50hz5p160t
        LuminanceSine100hz5p160t
        
        LuminanceSine1hz25p160t
        LuminanceSine5hz25p160t
        LuminanceSine10hz25p160t
        LuminanceSine15hz25p160t
        LuminanceSine20hz25p160t
        LuminanceSine25hz25p160t
        LuminanceSine30hz25p160t
        LuminanceSine50hz25p160t
        LuminanceSine100hz25p160t

        LuminanceSquare1hz5p160t
        LuminanceSquare5hz5p160t
        LuminanceSquare10hz5p160t
        LuminanceSquare15hz5p160t
        LuminanceSquare20hz5p160t
        LuminanceSquare25hz5p160t
        LuminanceSquare30hz5p160t
        LuminanceSquare50hz5p160t
        LuminanceSquare100hz5p160t
        
        LuminanceOffSawtooth1hz5p160t
        LuminanceOffSawtooth5hz5p160t
        LuminanceOffSawtooth10hz5p160t
        LuminanceOffSawtooth15hz5p160t
        LuminanceOffSawtooth20hz5p160t
        LuminanceOffSawtooth25hz5p160t
        LuminanceOffSawtooth30hz5p160t
        LuminanceOffSawtooth50hz5p160t
        LuminanceOffSawtooth100hz5p160t
        
        LuminanceOffSawtooth1hz25p160t
        LuminanceOffSawtooth5hz25p160t
        LuminanceOffSawtooth10hz25p160t
        LuminanceOffSawtooth15hz25p160t
        LuminanceOffSawtooth20hz25p160t
        LuminanceOffSawtooth25hz25p160t
        LuminanceOffSawtooth30hz25p160t
        LuminanceOffSawtooth50hz25p160t
        LuminanceOffSawtooth100hz25p160t

        LuminanceOnSawtooth1hz5p160t
        LuminanceOnSawtooth5hz5p160t
        LuminanceOnSawtooth10hz5p160t
        LuminanceOnSawtooth15hz5p160t
        LuminanceOnSawtooth20hz5p160t
        LuminanceOnSawtooth25hz5p160t
        LuminanceOnSawtooth30hz5p160t
        LuminanceOnSawtooth50hz5p160t
        LuminanceOnSawtooth100hz5p160t
        
        LuminanceOnSawtooth1hz25p160t
        LuminanceOnSawtooth5hz25p160t
        LuminanceOnSawtooth10hz25p160t
        LuminanceOnSawtooth15hz25p160t
        LuminanceOnSawtooth20hz25p160t
        LuminanceOnSawtooth25hz25p160t
        LuminanceOnSawtooth30hz25p160t
        LuminanceOnSawtooth50hz25p160t
        LuminanceOnSawtooth100hz25p160t

        % 110t temporal modulations
        LuminanceSine1hz25p110t
        LuminanceSine5hz25p110t
        LuminanceSine10hz25p110t
        LuminanceSine15hz25p110t
        LuminanceSine20hz25p110t
        LuminanceSine25hz25p110t
        LuminanceSine30hz25p110t
        LuminanceSine50hz25p110t
        LuminanceSine100hz25p110t

        LuminanceOnSawtooth1hz25p110t
        LuminanceOnSawtooth5hz25p110t
        LuminanceOnSawtooth10hz25p110t
        LuminanceOnSawtooth15hz25p110t
        LuminanceOnSawtooth20hz25p110t
        LuminanceOnSawtooth25hz25p110t
        LuminanceOnSawtooth30hz25p110t
        LuminanceOnSawtooth50hz25p110t
        LuminanceOnSawtooth100hz25p110t

        LuminanceOffSawtooth1hz25p110t
        LuminanceOffSawtooth5hz25p110t
        LuminanceOffSawtooth10hz25p110t
        LuminanceOffSawtooth15hz25p110t
        LuminanceOffSawtooth20hz25p110t
        LuminanceOffSawtooth25hz25p110t
        LuminanceOffSawtooth30hz25p110t
        LuminanceOffSawtooth50hz25p110t
        LuminanceOffSawtooth100hz25p110t

        LuminanceSquare10hz25p110t
        LuminanceSquare15hz25p110t
        LuminanceSquare20hz25p110t

        % Suppressed-by-contrast
        LuminanceSquare100hz2p80t
        LuminanceSquare100hz5p80t
        
        % Increments and decrements of varying types and lengths
        LuminanceIncrement20s80t
        LuminanceDecrement20s80t
        LuminanceIncrement10s80t
        LuminanceDecrement10s80t
        LuminanceIncrement5s80t
        LuminanceDecrement5s80t
        LuminanceIncrement3s80t
        LuminanceDecrement3s80t

        LuminanceIncrement2p35m20s80t

        % Intensity Increments
        IntensityIncrement0p10s60t
        IntensityIncrement0p10s80t
        IntensityIncrement0p20s80t

        BlueIncrement2p20s80t
        BlueIncrement5p20s80t

        LuminanceIncrement0p10s60t
        LuminanceIncrement0p10s80t
        LuminanceIncrement0p20s80t
        
        % Intensity response functions
        IntensitySeq0p105t
        IntensitySeq5p105t
        IntensitySeq10p105t
        IntensitySeq20p105t

        IntensitySeqLow0p105t
        IntensitySeqLow2p105t
        IntensitySeqLower0p105t

        RedIntensitySeqLow2p105t
        GreenIntensitySeqLow2p105t

        RedIntensitySeq2p5s150t
        GreenIntensitySeq2p5s150t
        BlueIntensitySeq2p5s150t
        WhiteIntensitySeq2p5s150t
        YellowIntensitySeq2p5s150t

        RedIntensitySeq2p5s160t
        GreenIntensitySeq2p5s160t
        BlueIntensitySeq2p5s160t
        YellowIntensitySeq2p5s160t
        WhiteIntensitySeq2p5s160t

        DecrementContrastSeq2p5s160t

        % Contrast response functions
        ContrastIncSeq50p105t
        ContrastDecSeq50p105t

        % Alternating contrast series
        ContrastAltSeq5s2p140t
        ContrastAltSeq5s10p140t
        ContrastAltSeq5s10p160t

        % Spectral response functions
        RgbSeq0p80t
        RgbSeq5p80t
        RgbSeq10p80t
        RgbSeq20p80t
        RgbSeq50p80t

        RgbSeq0p200t
        RgbSeq5p200t
        RgbSeq25p200t
        RgbSeq50p200t

        RgwSeq2p25m200t
        RgwSeq2p50m200t
        RgwSeq2p175m200t
        
        RgwSeq5p25m200t
        RgwSeq5p50m200t
        RgwSeq5p100m200t
        RgwSeq5p125m200t
        RgwSeq5p150m200t
        RgwSeq5p175m200t

        RgySeq5p25m200t
        RgySeq5p175m200t
        
        GrwSeq5p100m200t
        GrwSeq5p175m200t

        WgrSeq5p175m200t
     
        % Toptica simulations
        TopticaSimBaselineAdapt
        TopticaSimIncrement20s
        TopticaSimDecrement20s
        TopticaSimDecInc20s

        % Lights on and lights off
        LightsOn2p100t
        LightsOn5p100t
        LightsOn10p100t
        LightsOn20p100t
        LightsOn25p100t
        LightsOn50p100t

        LightsOff2p100t
        LightsOff5p100t
        LightsOff10p100t
        LightsOff20p100t
        LightsOff25p100t
        LightsOff50p100t

        % Misc stimuli
        LuminanceChirp
        LuminanceChirp50p110t
        LuminanceChirp50p240t
        LuminanceChirp5p160t
        LuminanceChirp10p160t
        LuminanceChirp5p190t
        LuminanceChirp10p190t
        LuminanceChirp50p190t
        LuminanceSquarewave1
        LuminanceSquare5hz50p100t

        % Tyler's Stimuli
        LConeSinewave015
        MConeSinewave015
        SConeSinewave015
        LumSinewave015
        ControlSinewave015
        
        % Outdated contrast-varying stimuli
        LmsxDecrement20s80t 
        LmsxIncrement20s80t
        LuminanceIncrement20s80tOld
        LuminanceDecrement20s80tOld
        LuminanceIncrementQuarter20s80t
        LuminanceDecrementQuarter20s80t
        LuminanceDoubleIncrementQuarter20s80t
        LuminanceTripleIncrementQuarter20s80t

        % Outdated 
        LightsOn
        LightsOnQuarter
        LightsOff 

        Other 
    end

    methods       
        function tf = isBaseline(obj)
            import ao.SpectralStimuli;
            
            if contains(char(obj), {'Background', 'Baseline'})
                 tf = true;
            else
                tf = false;
            end
        end

        function y = polarity(obj)
            stimName = char(obj);
            if contains(stimName, 'Increment')
                y = 1;
            elseif contains(stimName, 'Decrement')
                y = 0;
            else
                y = NaN;
            end
        end

        function f = startIndex(obj)
            % STARTINDEX
            %
            % Description:
            %   f = obj.startIndex()
            % ---------------------------------------------------------
            import ao.SpectralStimuli;

            if contains(char(obj), 'Chrip')
                f = 191;
            elseif contains(char(obj), '20s80t')
                f = 1000;
            end
            
        end

        function n = frames(obj, truncate)
            % FRAMES
            %
            % Description:
            %   Get the number of frames in the stimulus
            %
            % Syntax:
            %   n = obj.frames(truncate)
            % ---------------------------------------------------------
            import ao.SpectralStimuli;

            if nargin < 2
                truncate = true;
            end
            
            stimName = char(obj);

            switch stimName 
                case 'LmsxBackground'
                    n = 2000;
                case {'Background', 'BackgroundQuarter'}
                    n = 1500;
                case {'LightsOn'}
                    n = 1500;
                case 'LightsOnQuarter'
                    n = 759;
                case 'LuminanceChirp5p160t'
                    n = 4034;
                case {'LConeSinewave015','LumSinewave015','MConeSinewave015','SConeSinewave015','ControlSinewave015'}
                    n = 2020;
                otherwise
                    if contains(stimName, 'RgbSeq') && ~contains(stimName, '200t')
                        n = 2020;
                    elseif contains(stimName, '240t')
                        n = 6060;
                    elseif contains(stimName, '80t')
                        n = 2000;
                    elseif contains(stimName, '190t')
                        n = 4800;
                    elseif contains(stimName, '90t')
                        n = 2250;
                    elseif contains(stimName, '100t')
                        n = 2520;
                    elseif contains(stimName, '105t')
                        n = 2640;
                    elseif contains(stimName, '110t')
                        n = 2750;
                    elseif contains(stimName, '120t')
                        n = 3020;
                    elseif contains(stimName, '140t')
                        n = 3530;
                    elseif contains(stimName, '150t')
                        n = 3750;
                    elseif contains(stimName, '160t')
                        n = 4040;
                    elseif contains(stimName, '200t')
                        n = 5040;
                    elseif contains(stimName, '60t')
                        n = 1500;
                    elseif contains(stimName, 'Chirp')
                        n = 1500;
                    elseif contains(stimName, 'TopticaSim')
                        n = 4500;
                    end
            end

            if truncate
                n = n - 1;
            end
        end
        
        function bkgd = bkgd(obj, truncate)
            % BKGD
            %
            % Syntax:
            %   bkgd = bkgd(obj, truncate)
            %
            % Inputs:
            %   truncate    logical (default = true)
            %       Account for removal of the first blank frame
            % ---------------------------------------------------------
            import ao.SpectralStimuli;
            
            if nargin < 2
                truncate = true;
            end

            stimName = char(obj);

            switch stimName
                case SpectralStimuli.LightsOff
                    bkgd = [10 490];
                case SpectralStimuli.LuminanceSteps120t
                    bkgd = [20 370];
                case SpectralStimuli.LightsOn
                    bkgd = [250 490];
                case {SpectralStimuli.LuminanceChirp5p190t, SpectralStimuli.LuminanceChirp5p160t, SpectralStimuli.LuminanceChirp10p160t, SpectralStimuli.LuminanceChirp10p190t, SpectralStimuli.LuminanceChirp50p190t}
                    bkgd = [250 498];
                case {'LConeSinewave015','LumSinewave015','MConeSinewave015','SConeSinewave015','ControlSinewave015'}
                    bkgd = [];
                otherwise
                    if contains(stimName, 'LuminanceIncrement0p')
                        bkgd = [250 498];
                    elseif contains(stimName, 'Chirp')
                        bkgd = [30 180]; % [1 190];
                    elseif contains(stimName, '100t')
                        bkgd = [350 490];
                    elseif contains(stimName, 'Steps120t')
                        bkgd = [50 375];
                    elseif contains(stimName, 'Steps110t')
                        bkgd = [300 495];
                    elseif contains(stimName, {'IntensitySeq', 'ContrastAltSeq', 'RgbSeq', 'RgwSeq', 'RgySeq', 'GrwSeq', 'ContrastDecSeq', 'ContrastIncSeq', 'ContrastSeq'})
                        bkgd = [200 495];
                    elseif contains(stimName, 'Sine160t')
                        bkgd = [350 495];
                    elseif contains(stimName, {'Steps', 'Square', 'DecInc', 'Sine', 'Sawtooth'})
                        bkgd = [200 490]; % [1 500]
                    elseif contains(stimName, '20s80t')
                        if contains(stimName, 'Old')
                            bkgd = [200 740];
                        else  % cone, lmsx
                            bkgd = [200 490];% [1 500];
                        end
                    elseif contains(stimName, {'5s80t', '10s80t', '3s80t'})
                        bkgd = [20 490];
                    elseif contains(stimName, 'TopticaSim')
                        bkgd = [3000 3200];
                    else
                        bkgd = [];
                    end
            end
            
            if truncate && ~isempty(bkgd)
                bkgd(2) = bkgd(2) - 1;
            end
        end
     
        function signal = signal(obj, truncate)
            % SIGNAL
            %
            % Syntax:
            %   signal = signal(obj, truncate)
            %
            % Inputs:
            %   truncate    logical (default = true)
            %       Account for removal of the first blank frame
            % ---------------------------------------------------------
            import ao.SpectralStimuli;
            if nargin < 2
                truncate = true;
            end
            
            switch obj
                case SpectralStimuli.Background
                    signal = [500 1500];
                case SpectralStimuli.LuminanceSteps120t
                    signal = [376 2250];
                case SpectralStimuli.LuminanceChirp 
                    signals = [196 1315];
                otherwise
                    stimName = char(obj);
                    if contains(stimName, 'TopticaSim')
                        signal = [3250 3750];
                    elseif contains(stimName, 'Steps_150t')
                        signal = [500 2000];
                    elseif contains(stimName, 'Square')
                        signal = [506 3036];
                    elseif contains(stimName, 'Steps120t')
                        signal = [380 2280];
                    elseif contains(stimName, '20s80t') 
                        if contains(stimName, 'Old')
                            signal = [750 1250];
                        else  % cone, lmsx
                            signal = [507 1012];
                        end
                    elseif contains(stimName, '10s80t')
                        signal = [507 750];
                    elseif contains(stimName, '5s80t')
                        signal = [507 1500]; 
                    elseif contains(stimName, '3s80t')
                        signal = [507 1575];
                    else
                        signal = [];
                    end
            end
            
            if truncate
                signal = signal - 1;
            end
        end

        function [ups, downs] = getStimWindows(obj, dataset, epochID, frameFlag)
            if nargin < 4
                frameFlag = true;
            end
            if nargin < 3 || isempty(epochID)
                epochID = dataset.stim2epochs(obj);
            end

            % Assuming the epochs are all the same stim, just take the 1st
            if numel(epochID) > 1
                epochID = epochID(1);
            end
            
            stimName = char(obj);
            ups = [];
            downs = [];

            if contains(stimName, 'Square')
                if contains(stimName, 'Scone')
                    [ups, downs] = getSquareModulationTiming(dataset.frameTables(epochID), 3, frameFlag);
                else
                    [ups, downs] = getSquareModulationTiming(dataset.frameTables(epochID), 1, frameFlag);
                end
            elseif contains(stimName, 'RgbSeq') 
                for i = 1:3
                    ups = cat(1, ups, dataset.getFrameTables(epochID, i, frameFlag));
                end
            elseif contains(stimName, 'RgwSeq') || contains(char(obj), 'GrwSeq')
                for i = 1:3
                    tmp = getSquareModulationTiming(dataset.frameTables(epochID), i, frameFlag);
                    ups = cat(1, ups, tmp(1,:));
                end
            elseif contains(stimName, 'RgySeq')              
                    ups = getSquareModulationTiming(dataset.frameTables(epochID), 1, frameFlag);
                    ups = cat(1, ups,...
                        getSquareModulationTiming(dataset.frameTables(epochID), 2, frameFlag));
            elseif contains(stimName, 'Chirp') && contains(stimName, '190t')
                [ups, downs] = getSquareModulationTiming(dataset.frameTables(epochID), 4, frameFlag);
                ups(2,2) = ups(end,2);
                ups(3:end,:) = [];
                downs(2:end,:) = [];
            elseif contains(stimName, 'Chirp') && contains(stimName, '160t')
                ups = getSquareModulationTiming(dataset.frameTables(epochID), 4, frameFlag);
                ups(2,2) = ups(end,2);
            else
                [ups, downs] = getSquareModulationTiming(dataset.frameTables(epochID), 4, frameFlag);
            end
        end
                 
        function stim = trace(obj, truncate)
            % TRACE
            %
            % Description:
            %   Get the LED timecourse
            %
            % Syntax:
            %   stim = trace(obj, truncate)
            %
            % ---------------------------------------------------------
            import ao.SpectralStimuli;

            if nargin < 2
                truncate = true;
            end

            stim = 0.5 * ones(1, obj.frames());
            
            stimName = char(obj);

            if contains(stimName, 'LightsOn')
                stim(1:505) = 0;
            elseif contains(stimName, 'Steps110t')
                stim(506:1011) = 1;
                stim(1012:1518) = 0;
                stim(1519:2024) = 1;
            elseif contains(stimName, 'Steps120t')
                stim(380:759) = 1;
                stim(760:1138) = 0;
                stim(1139:1518) = 1;
                stim(1519:1898) = 0;
                stim(1899:2280) = 1;
            elseif contains(stimName, 'Square150t')
                stim(506:1011) = 1;
                stim(1012:1518) = 0;
                stim(1519:2024) = 1;
                stim(2025:2530) = 0;
                stim(2531:3036) = 1;
            elseif contains(stimName, 'Square160t')
                stim(506:1011) = 1;
                stim(1012:1518) = 0;
                stim(1519:2024) = 1;
                stim(2025:2530) = 0;
                stim(2531:3036) = 1;
                if contains(stimName, 'Luminance')
                    stim = -1 * (stim-0.5) + 0.5;
                end
            elseif contains(stimName, 'Sine160t')
                modTime = [20 120];
                modPts = modTime * (1000 / 1/25);

                t = 1:(modPts(2)-modPts(1));
                t = t / 25;
                temporalFrequency = 1/40;
                stim(modPts(1)+1:modPts(2)) = 0.5 * sign(sin(temporalFrequency * 2 * pi * t)) + 0.5;
            elseif contains(stimName, 'DecInc')
                stim(501:1000) = 0;
                stim(1001:1500) = 1;
            elseif contains(stimName, 'Increment20s80t')
                stim = obj.addPulse(stim, obj.signal, 1);
            elseif contains(stimName, 'Decrement20s80t')
                stim = obj.addPulse(stim, obj.signal, 0);
            elseif contains(stimName, 'Decrement10s80t')
                stim = obj.addPulse(stim, obj.signal, 0);
            elseif contains(stimName, 'Decrement5s80t')
                stim = obj.addPulse(stim, [501 625], 0);
                stim = obj.addPulse(stim, [1375 1500], 0);
            elseif contains(stimName, 'Decrement3s80t')
                % modTime = [20 23; 40 43; 60 63];
                stim = obj.addPulse(stim, [501, 575], 0);
                stim = obj.addPulse(stim, [1001, 1075], 0);
                stim = obj.addPulse(stim, [1501, 1575], 0);
            elseif contains(stimName, 'TopticaSim')
                ledResolution = 1 / obj.LED_RATE * 1000;  % ms
                frameResolution = 1 / obj.FRAME_RATE * 1000;  % ms

                stimTime = obj.frames() * (1 / obj.FRAME_RATE);  % s
                stimPts = stimTime * 1000 / ledResolution;
                framePts = 40 / ledResolution;

                numReps = ceil(stimPts / framePts);
                toptica = zeros(1, framePts);
                toptica(10) = 0.5;

                stim = repmat(toptica, [1 numReps]);
                stim = stim(1:stimPts);     % Clip just in case

                if contains(stimName, 'Increment')
                    modTime = [130 150] * 1000 / ledResolution;
                    modPts = modTime * 1000 / ledResolution;
                    stim(modPts(1):modPts(2)) = 2 * stim(modPts(1):modPts(2));
                elseif contains(stimName, 'Decrement')
                    modTime = [130 150] * 1000 / ledResolution;
                    modPts = modTime * 1000 / ledResolution;
                    stim(modPts(1):modPts(2)) = 0;
                end
            end 
            
            if truncate
                stim = stim((obj.FRAME_RATE+1):end);
            end
        end

        function app = openRoiAverageView(obj, dataset)
            % OPENROIAVERAGEVIEW
            % 
            % Description:
            %   Open RoiAverageView with stim-specific defaults
            %
            % Syntax:
            %   app = obj.openRoiAverageView(dataset)
            % -------------------------------------------------------------
            import ao.SpectralStimuli;        

            % epochIDs = dataset.stim2epochs(obj);
            epochIDs = dataset.epochIDs(dataset.ledStimNames == obj);

            titleStr = [char(dataset.experimentDate), ' ', char(obj)];

            if contains(char(obj), {'20s80t', '10s80t'})
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,... 
                    obj.signal, titleStr);
            elseif contains(char(obj), 'Chirp')
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.signal, titleStr, dataset.getEpochTrace(epochIDs(1)));
            elseif contains(char(obj), {'SconeSquare', 'BlueIncrement'})
                disp('yay scones')
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.getStimWindows(dataset, epochIDs(1), true), ...
                    titleStr, dataset.frameTables(epochIDs(1)));
            elseif contains(char(obj), {'Steps', 'Square', 'DecInc'})
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    [], titleStr, dataset.getEpochTrace(epochIDs));
            elseif contains(char(obj), 'TopticaSim')
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.signal, titleStr, obj.trace(true));
            elseif contains(char(obj), 'Background')
                app = RoiAverageView2(dataset, epochIDs, [],... 
                        [], titleStr);
            elseif contains(char(obj), {'LightsOn', 'LightsOff'})
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    [], titleStr, dataset.getEpochTrace(epochIDs));
            elseif contains(char(obj), {'RgbSeq', 'RgwSeq', 'GrwSeq', 'RgySeq'})
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.getStimWindows(dataset, epochIDs(1), true), ...
                    titleStr, dataset.frameTables(epochIDs(1)));
            elseif contains(char(obj), 'IntensitySeq')
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.getStimWindows(dataset, epochIDs(1), true), ...
                    titleStr, dataset.frameTables(epochIDs(1)));
            else
                warning('Using generic interface!');
                app = RoiAverageView2(dataset, epochIDs, obj.bkgd,...
                    obj.signal, titleStr, dataset.getEpochTrace(epochIDs(1),4));
            end
        end
    end

    methods
        function [ax, h] = makeMultiplot(obj, dataset, roiID, varargin)

            if ~isnumeric(roiID)
                roiID = dataset.uid2roi(roiID);
            end

            ip = inputParser();
            addParameter(ip, 'AvgOnly', true, @islogical);
            addParameter(ip, 'Method', 'dff', @ischar);
            addParameter(ip, 'Norm', false, @islogical);
            addParameter(ip, 'Color', [], @isnumeric);
            addParameter(ip, 'Parent', [], @ishandle);
            addParameter(ip, 'LineWidth', 1.25, @isnumeric);
            addParameter(ip, 'Clip', [], @isnumeric);
            addParameter(ip, 'Omit', [], @isnumeric);
            parse(ip, varargin{:});

            normFlag = ip.Results.Norm; 
            avgOnly = ip.Results.AvgOnly;
            omitIdx = ip.Results.Omit;
            clipValue = ip.Results.Clip;
            LW = ip.Results.LineWidth;
            
            avgColor = ip.Results.Color;
            if isempty(avgColor)
                [avgColor, allColor] = obj.getStimColor();
            else
                allColor = lighten(avgColor, 0.6);
            end

            ax = ip.Results.Parent;
            if ~isempty(ax)
                delete(findall(ax, 'Tag', 'StimPatch'));
                hold(ax, 'on');
            else
                ax = axes('Parent', figure()); hold on;
                ax.Parent.PaperPositionMode = 'auto';
            end


            stimName = lower(char(obj));
            [signals, xpts] = dataset.getStimulusResponses(char(obj), obj.bkgd, ...
                'Method', ip.Results.Method, 'Smooth', 100);
            if isempty(signals) || size(signals, 1) == 0
                error('ROI not found!');
            end

            % Omit epochs, if necessary
            if ~isempty(omitIdx)
                signals(:,:,omitIdx) = [];
            end

            if ndims(signals) == 3
                if ~isempty(clipValue)
                    signals = signals(:, clipValue:end-clipValue+1, :);
                    xpts = xpts(clipValue:end-clipValue+1);
                end
                signals = signals(roiID, :, :);
                avgSignal = mean(signals,3);
            else
                if ~isempty(clipValue)
                    signals = signals(:, clipValue:end-clipValue+1);
                    xpts = xpts(clipValue:end-clipValue+1);
                end
                signals = signals(roiID,:);
                avgSignal = signals;
            end
            if normFlag
                avgSignal = avgSignal/max(abs(avgSignal));
                signals = signals/max(abs(signals), [], "all");
            end
            [ups, downs] = obj.getStimWindows(dataset, dataset.stim2epochs(obj), false);

            title([char(dataset.roiUIDs{roiID, 'UID'}), ' - ', char(obj)]);
            % Responses
            h = plot(xpts, avgSignal, 'LineWidth', LW, 'Color', avgColor,...
                'Tag', [char(dataset.experimentDate), '_', num2str(roiID), '_', char(obj)]);
            if ~avgOnly && size(signals,3) > 1
                for i = 1:size(signals,3)
                    plot(xpts, signals(1,:,i), 'LineWidth', 0.3, 'Color', allColor);
                end
            end
            setYAxisZScore2(ax, [0.5 1], true);
            % Stimulus specific plotting
            if contains(stimName, 'blue')
                addStimPatch(ax, ups, 'FaceColor', hex2rgb('334def'));
            elseif contains(stimName, 'red')
                addStimPatch(ax, ups, 'FaceColor', hex2rgb('ff4040'));
            elseif contains(stimName, 'green')
                addStimPatch(ax, ups, 'FaceColor', hex2rgb('00cc4d'));
            elseif contains(stimName, 'yellow')
                addStimPatch(ax, ups, 'FaceColor', rgb('peach'));
            elseif contains(stimName, {'rgb','rgw','rgy'})
                addStimPatch(ax, ups(1,:), 'FaceColor', hex2rgb('ff4040'));
                addStimPatch(ax, ups(2,:), 'FaceColor', hex2rgb('00cc4d'));
                if contains(stimName, 'rgb')
                    addPatch(ax, ups(3,:), 'FaceColor', hex2rgb('334de6'));
                elseif contains(stimName, 'rgy')
                    addPatch(ax, ups(3,:), 'FaceColor', rgb('peach'));
                else
                    addStimPatch(ax, ups(3,:), obj.INC_PROPS{:});
                end
            else  % Default plot
                if ~isempty(ups)
                    addStimPatch(ax, ups, obj.INC_PROPS{:});
                end
                if ~isempty(downs)
                    addStimPatch(ax, downs, obj.DEC_PROPS{:});
                end
            end
            setXLimitsAndTicks(10*floor((0.04*obj.frames)/10), 20, ax, false);
            addZeroBarIfNeeded(ax);
            reverseChildOrder(ax);
            if isempty(ip.Results.Parent)
                figPos(gcf, 0.5, 0.3);  % Only do this once
            end
            drawnow;
        end

        function [avgColor, allColor] = getStimColor(~)
            avgColor = [0.1 0.1 0.2];
            allColor = lighten(avgColor, 0.7);
        end
    end
    
    methods (Static)
        function stim = addPulse(stim, stimWindow, value)
            % ADDPULSE
            %
            % Syntax:
            %   stim = ao.SpectralStimuli.addPulse(stim, stimWindow, value)
            % -------------------------------------------------------------
            ind = window2idx(stimWindow);
            stim(ind) = value;
        end
        
        function x = frames2leds(nFrames, truncate)
            if nargin < 2
                truncate = true;
            end
            
            t = nFrames * (1/ao.SpectralStimuli.FRAME_RATE);
            
            ledTime = 1 / obj.LED_RATE;
            nLedPts = t / ledTime;

            x = 1:nLedPts;
            x = ledTime * x + ledTime;
            
            if truncate
                x(1) = [];
            end
        end

        function obj = init(str)
            % INIT
            %
            % Description:
            %   Initialize object from stimulus name
            %
            % Syntax:
            %   obj = init(str)
            %
            % Inputs:
            %   str         char
            %       Stimulus name or stimulus file name
            % ---------------------------------------------------------

            import ao.SpectralStimuli;

            try 
                obj = SpectralStimuli.(str);
                return
            end

            if isstring(str)
                str = char(str);
            end

            
            if ismember('\', char(str)) % Stimulus files have PC filesep
                str = strsplit(str, '\');
                str = str{end};
            end
            
            if strcmp(str(end), ' ')
                str = str(1:end-1);
            end
            
            str = erase(str, '.txt');
            str = erase(str, '_right');
            str = erase(str, '_left');
            str = erase(str, ',');
            
            str = strrep(str, ' ', '_');

            switch lower(str)
                case 'lcone_increment_20s_80t'
                    obj = SpectralStimuli.LconeIncrement20s80t;
                case 'lcone_decrement_20s_80t'
                    obj = SpectralStimuli.LconeDecrement20s80t;
                case 'mcone_increment_20s_80t'
                    obj = SpectralStimuli.MconeIncrement20s80t;
                case 'mcone_decrement_20s_80t'
                    obj = SpectralStimuli.MconeDecrement20s80t;
                case 'scone_increment_20s_80t'
                    obj = SpectralStimuli.SconeIncrement20s80t;
                case 'scone_decrement_20s_80t'
                    obj = SpectralStimuli.SconeDecrement20s80t;
                case 'lmcone_increment_20s_80t'
                    obj = SpectralStimuli.LMconeIncrement20s80t;
                case 'lmcone_decrement_20s_80t'
                    obj = SpectralStimuli.LMconeDecrement20s80t;
                    
                case 'lmcone_steps_110t'
                    obj = SpectralStimuli.LMconeSteps110t;
                case 'lcone_steps_110t'
                    obj = SpectralStimuli.LconeSteps110t;
                case 'mcone_steps_110t'
                    obj = SpectralStimuli.MconeSteps110t;
                case 'scone_steps_110t'
                    obj = SpectralStimuli.SconeSteps110t;
                    
                case 'lmcone_square_150t'
                    obj = SpectralStimuli.LMconeSquare150t;
                case 'lcone_square_150t'
                    obj = SpectralStimuli.LconeSquare150t;
                case 'mcone_square_150t'
                    obj = SpectralStimuli.MconeSquare150t;
                case 'scone_square_150t'
                    obj = SpectralStimuli.SconeSquare150t;
                    
                case 'luminance_square_160t'
                    obj = SpectralStimuli.LuminanceSquare160t;
                case 'isoluminance_square_160t'
                    obj = SpectralStimuli.IsoluminanceSquare160t;
                case 'lmcone_square_160t'
                    obj = SpectralStimuli.LMconeSquare160t;
                case 'lcone_square_160t'
                    obj = SpectralStimuli.LconeSquare160t;
                case 'mcone_square_160t'
                    obj = SpectralStimuli.MconeSquare160t;
                case 'scone_square_160t'
                    obj = SpectralStimuli.SconeSquare160t;

                    
                case 'luminance_chirp'
                    obj = SpectralStimuli.LuminanceChirp;
                case 'luminance_squarewave_1hz'
                    obj = SpectralStimuli.LuminanceSquarewave1;
                    
                case 'luminance_increment_20s_80t'
                    obj = SpectralStimuli.LuminanceIncrement20s80t;
                case 'luminance_increment_10s_80t'
                    obj = SpectralStimuli.LuminanceIncrement10s80t;
                case 'luminance_increment_5s_80t'
                    obj = SpectralStimuli.LuminanceIncrement5s80t;
                case 'luminance_increment_3s_80t'
                    obj = SpectralStimuli.LuminanceIncrement3s80t;
                case 'luminance_decrement_20s_80t'
                    obj = SpectralStimuli.LuminanceDecrement20s80t;
                case 'luminance_decrement_10s_80t'
                    obj = SpectralStimuli.LuminanceDecrement10s80t;
                case 'luminance_decrement_5s_80t'
                    obj = SpectralStimuli.LuminanceDecrement5s80t;
                case 'luminance_decrement_3s_80t'
                    obj = SpectralStimuli.LuminanceDecrement3s80t;
                    
                case 'topticasim_background_adapt'
                    obj = SpectralStimuli.TopticaSimBaselineAdapt;
                case 'topticasim_contrast_increment_20s_adapt'
                    obj = SpectralStimuli.TopticaSimIncrement20s;
                case 'topticasim_contrast_decrement_20s_adapt'
                    obj = SpectralStimuli.TopticaSimDecrement20s;
                    
                case {'lmsx_background', 'baseline'}
                    obj = SpectralStimuli.LmsxBackground;
                case 'luminance_background_80t'
                    obj = SpectralStimuli.LuminanceBaseline;
                    
                case 'lightson'
                    obj = SpectralStimuli.LightsOn;
                case 'lightsoff'
                    obj = SpectralStimuli.LightsOff;
                    
                otherwise
                    obj = SpectralStimuli.Other;
                    warning('Unrecognized stimulus %s', char(str));
            end
        end
    end
end 