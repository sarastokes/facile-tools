classdef Stimuli
% STIMULI
%
% Description:
%   Stimulus attributes for display/analysis purposes
%
% History:
%   20201204 - SSP
% -------------------------------------------------------------------------

    enumeration
        LightsOn
        LightsOff

        % BASELINE --------------------------------------------------------
        Baseline
        Baseline50p70s
        BaselineLong
        BaselineZeroMean
        BaselineLongZeroMean

        % FULL FIELD INTENSITY INCREMENTS ---------------------------------
        IntensityIncrement1s80t
        IntensityIncrement3s80t
        IntensityIncrement5s80t
        IntensityIncrement10s80t
        IntensityIncrement20s80t
        IntensityIncrement80s180t

        IntensityIncrement50c10s80t

        % FULL FIELD CONTRAST STEPS ---------------------------------------
        ContrastIncrement20
        ContrastDecrement20
        ContrastIncrement20Long
        ContrastDecrement20Long
        ContrastIncrement20Half
        ContrastDecrement20Half
        ContrastIncrement20Quarter
        ContrastDecrement20Quarter
        ContrastIncrement10a
        ContrastDecrement10a
        ContrastIncrement10Half
        ContrastDecrement10Half
        ContrastIncrement10
        ContrastDecrement10
        ContrastIncrement5
        ContrastDecrement5
        ContrastIncrement3
        ContrastDecrement3

        ContrastIncrement20s80t
        ContrastDecrement20s80t
        ContrastIncrement100c20s70t
        ContrastDecrement100c20s70t
        ContrastIncrement75c20s70t
        ContrastDecrement75c20s70t
        ContrastIncrement50c20s70t
        ContrastDecrement50c20s70t
        ContrastIncrement25c20s70t
        ContrastDecrement25c20s70t
        ContrastIncrement10c20s70t
        ContrastDecrement10c20s70t

        ContrastDecrementIncrement20s90t

        TemporalSquarewave05
        TemporalSquarewave1
        TemporalContrastSquarewave05

        Chirp
        ShortChirp

        % INDIVIDUAL BARS -------------------------------------------------
        % Iteration One
        Bar1of8
        Bar2of8
        Bar3of8
        Bar4of8
        Bar5of8
        Bar6of8
        Bar7of8
        Bar8of8

        HorizontalBar1of8
        HorizontalBar2of8
        HorizontalBar3of8
        HorizontalBar4of8
        HorizontalBar5of8
        HorizontalBar6of8
        HorizontalBar7of8
        HorizontalBar8of8

        % Iteration Two
        Bar1of16
        Bar2of16
        Bar3of16
        Bar4of16
        Bar5of16
        Bar6of16
        Bar7of16
        Bar8of16
        Bar9of16
        Bar10of16
        Bar11of16
        Bar12of16
        Bar13of16
        Bar14of16
        Bar15of16
        Bar16of16

        % Iteration Three
        Bar4of32
        Bar5of32
        Bar6of32
        Bar7of32
        Bar8of32
        Bar9of32
        Bar10of32
        Bar11of32
        Bar12of32
        Bar13of32
        Bar14of32
        Bar15of32
        Bar16of32
        Bar17of32
        Bar18of32
        Bar19of32
        Bar20of32
        Bar21of32
        Bar22of32
        Bar23of32
        Bar24of32
        Bar25of32
        Bar26of32
        Bar27of32
        Bar28of32

        % Iteration 4
        DecrementIncrementBar4of32
        DecrementIncrementBar5of32
        DecrementIncrementBar6of32
        DecrementIncrementBar7of32
        DecrementIncrementBar8of32
        DecrementIncrementBar9of32
        DecrementIncrementBar10of32
        DecrementIncrementBar11of32
        DecrementIncrementBar12of32
        DecrementIncrementBar13of32
        DecrementIncrementBar14of32
        DecrementIncrementBar15of32
        DecrementIncrementBar16of32
        DecrementIncrementBar17of32
        DecrementIncrementBar18of32
        DecrementIncrementBar19of32
        DecrementIncrementBar20of32
        DecrementIncrementBar21of32
        DecrementIncrementBar22of32
        DecrementIncrementBar23of32
        DecrementIncrementBar24of32
        DecrementIncrementBar25of32
        DecrementIncrementBar26of32
        DecrementIncrementBar27of32
        DecrementIncrementBar28of32
        DecrementIncrementBar29of32
        DecrementIncrementBar30of32

        HorizontalDecrementIncrementBar4of32
        HorizontalDecrementIncrementBar5of32
        HorizontalDecrementIncrementBar6of32
        HorizontalDecrementIncrementBar7of32
        HorizontalDecrementIncrementBar8of32
        HorizontalDecrementIncrementBar9of32
        HorizontalDecrementIncrementBar10of32
        HorizontalDecrementIncrementBar11of32
        HorizontalDecrementIncrementBar12of32
        HorizontalDecrementIncrementBar13of32
        HorizontalDecrementIncrementBar14of32
        HorizontalDecrementIncrementBar15of32
        HorizontalDecrementIncrementBar16of32
        HorizontalDecrementIncrementBar17of32
        HorizontalDecrementIncrementBar18of32
        HorizontalDecrementIncrementBar19of32
        HorizontalDecrementIncrementBar20of32
        HorizontalDecrementIncrementBar21of32
        HorizontalDecrementIncrementBar22of32
        HorizontalDecrementIncrementBar23of32
        HorizontalDecrementIncrementBar24of32
        HorizontalDecrementIncrementBar25of32
        HorizontalDecrementIncrementBar26of32
        HorizontalDecrementIncrementBar27of32
        HorizontalDecrementIncrementBar28of32
        HorizontalDecrementIncrementBar29of32
        HorizontalDecrementIncrementBar30of32

        % Iteration Five
        IntensityBar10s10of32
        IntensityBar10s11of32
        IntensityBar10s12of32
        IntensityBar10s13of32
        IntensityBar10s15of32
        IntensityBar10s20of32
        IntensityBar10s25of32
        IntensityBar10s30of32

        HorizontalIntensityBar10of32
        HorizontalIntensityBar11of32
        HorizontalIntensityBar12of32
        HorizontalIntensityBar13of32
        HorizontalIntensityBar14of32
        HorizontalIntensityBar15of32
        HorizontalIntensityBar16of32
        HorizontalIntensityBar17of32
        HorizontalIntensityBar18of32
        HorizontalIntensityBar19of32
        HorizontalIntensityBar20of32
        HorizontalIntensityBar21of32
        HorizontalIntensityBar22of32
        HorizontalIntensityBar23of32
        HorizontalIntensityBar24of32
        HorizontalIntensityBar25of32
        HorizontalIntensityBar26of32
        HorizontalIntensityBar27of32

        % Failed experiment for horizontal bars
        HorizontalIntensityBar39of64
        HorizontalIntensityBar40of64

        % Iteration Five, half contrast and full contrast
        IntensityBar10of32
        IntensityBar15of32
        IntensityBar20of32
        IntensityBar25of32
        IntensityBar30of32

        IntensityBar10s50c80t1of32
        IntensityBar10s50c80t2of32
        IntensityBar10s50c80t3of32
        IntensityBar10s50c80t4of32
        IntensityBar10s50c80t5of32
        IntensityBar10s50c80t6of32
        IntensityBar10s50c80t7of32
        IntensityBar10s50c80t8of32
        IntensityBar10s50c80t9of32
        IntensityBar10s50c80t10of32
        IntensityBar10s50c80t11of32
        IntensityBar10s50c80t12of32
        IntensityBar10s50c80t13of32
        IntensityBar10s50c80t14of32
        IntensityBar10s50c80t15of32
        IntensityBar10s50c80t16of32
        IntensityBar10s50c80t17of32
        IntensityBar10s50c80t18of32
        IntensityBar10s50c80t19of32
        IntensityBar10s50c80t20of32
        IntensityBar10s50c80t21of32
        IntensityBar10s50c80t22of32
        IntensityBar10s50c80t23of32
        IntensityBar10s50c80t24of32
        IntensityBar10s50c80t25of32
        IntensityBar10s50c80t26of32
        IntensityBar10s50c80t27of32
        IntensityBar10s50c80t28of32
        IntensityBar10s50c80t29of32
        IntensityBar10s50c80t30of32
        IntensityBar10s50c80t31of32
        IntensityBar10s50c80t32of32

        % SPACED BAR MAPPING ----------------------------------------------
        % Iteration One
        SpacedOutBars1of8
        SpacedOutBars2of8
        SpacedOutBars3of8
        SpacedOutBars4of8
        SpacedOutBars5of8
        SpacedOutBars6of8
        SpacedOutBars7of8
        SpacedOutBars8of8

        SpacedOutBars1of7
        SpacedOutBars2of7
        SpacedOutBars3of7
        SpacedOutBars4of7
        SpacedOutBars5of7
        SpacedOutBars6of7
        SpacedOutBars7of7

        % Iteration Two
        SpacedOutIncrementBars1of7
        SpacedOutIncrementBars2of7
        SpacedOutIncrementBars3of7
        SpacedOutIncrementBars4of7
        SpacedOutIncrementBars5of7
        SpacedOutIncrementBars6of7
        SpacedOutIncrementBars7of7

        % Iteration Three
        SpacedOutDecrementIncrementBars1of7
        SpacedOutDecrementIncrementBars2of7
        SpacedOutDecrementIncrementBars3of7
        SpacedOutDecrementIncrementBars4of7
        SpacedOutDecrementIncrementBars5of7
        SpacedOutDecrementIncrementBars6of7
        SpacedOutDecrementIncrementBars7of7

        SpacedOutDecrementIncrementBars3pix1of9
        SpacedOutDecrementIncrementBars3pix2of9
        SpacedOutDecrementIncrementBars3pix3of9
        SpacedOutDecrementIncrementBars3pix4of9
        SpacedOutDecrementIncrementBars3pix5of9
        SpacedOutDecrementIncrementBars3pix6of9
        SpacedOutDecrementIncrementBars3pix7of9
        SpacedOutDecrementIncrementBars3pix8of9
        SpacedOutDecrementIncrementBars3pix9of9

        % Iteration 4
        SpacedOutIntensityBars1of9
        SpacedOutIntensityBars2of9
        SpacedOutIntensityBars3of9
        SpacedOutIntensityBars4of9
        SpacedOutIntensityBars5of9
        SpacedOutIntensityBars6of9
        SpacedOutIntensityBars7of9
        SpacedOutIntensityBars8of9
        SpacedOutIntensityBars9of9

        SpacedOutIntensityBars25i1of9
        SpacedOutIntensityBars25i2of9
        SpacedOutIntensityBars25i3of9
        SpacedOutIntensityBars25i4of9
        SpacedOutIntensityBars25i5of9
        SpacedOutIntensityBars25i6of9
        SpacedOutIntensityBars25i7of9
        SpacedOutIntensityBars25i8of9
        SpacedOutIntensityBars25i9of9

        % Iteration 5
        SpacedOutIntensityBars2pix7of32
        SpacedOutIntensityBars2pix8of32
        SpacedOutIntensityBars2pix9of32
        SpacedOutIntensityBars2pix10of32
        SpacedOutIntensityBars2pix11of32
        SpacedOutIntensityBars2pix12of32
        SpacedOutIntensityBars2pix13of32
        SpacedOutIntensityBars2pix14of32
        SpacedOutIntensityBars2pix15of32
        SpacedOutIntensityBars2pix16of32
        SpacedOutIntensityBars2pix17of32
        SpacedOutIntensityBars2pix18of32
        SpacedOutIntensityBars2pix19of32

        % Fast mapping
        SpacedOutBars1of4
        SpacedOutBars2of4
        SpacedOutBars3of4
        SpacedOutBars4of4

        SpacedOutVerticalBars1of4
        SpacedOutVerticalBars2of4
        SpacedOutVerticalBars3of4
        SpacedOutVerticalBars4of4

        % SQUARES ---------------------------------------------------------
        IntensityIncrement1On4OffSquares4x4
        IntensityIncrement1On4OffSquares4x4Baseline
        IntensityIncrement1On4OffSquares6x6

        % SEQUENTIALBARS --------------------------------------------------
        SequentialBarDecrement4to12of16

        % MOVING BARS -----------------------------------------------------
        VerticalMovingBar

        MovingBar0
        MovingBar90
        MovingBar180
        MovingBar270

        MovingBarN  % 25pix
        MovingBarS
        MovingBarE
        MovingBarW

        MovingBar15pix0
        MovingBar15pix30
        MovingBar15pix60
        MovingBar15pix90
        MovingBar15pix120
        MovingBar15pix150
        MovingBar15pix180
        MovingBar15pix210
        MovingBar15pix240
        MovingBar15pix270
        MovingBar15pix300
        MovingBar15pix330

        MovingBar8pix0
        MovingBar8pix30
        MovingBar8pix60
        MovingBar8pix90
        MovingBar8pix120
        MovingBar8pix150
        MovingBar8pix180
        MovingBar8pix210
        MovingBar8pix240
        MovingBar8pix270
        MovingBar8pix300
        MovingBar8pix330

        MovingBarCardinal18pix1v180t
        MovingBarDiagonal18pix1v180t
        MovingBarCardinal20pix1v180t
        MovingBarDiagonal20pix1v180t
        MovingBarCardinal20pix2v180t
        MovingBarDiagonal20pix2v180t
        MovingBarCardinal20pix3v180t

        MovingBarFullCardinal20pix1v180t
        MovingBarFullDiagonal20pix1v180t


        % MELANOPSIN ------------------------------------------------------
        Melanopsin_22m_180t
        Melanopsin_27m_180t

        % FULL-FIELD NOISE ------------------------------------------------
        TemporalNoise16
        TemporalNoise20
        TemporalNoise42
        TemporalNoise35
        TemporalNoise11
        TemporalBinaryNoise16
        TemporalBinaryNoise20
        TemporalBinaryNoise42
        TemporalBinaryNoise35
        TemporalBinaryNoise11


        % TOPTICA SIM -----------------------------------------------------
        TopticaSimBaselineAdapt
        TopticaSimIncrement20s

        % SPECTRAL --------------------------------------------------------
        % Only here for backwards compatibility
        LMConeDecrement
        LMConeIncrement
        LConeIncrement
        LConeDecrement
        MConeIncrement
        MConeDecrement
        SConeIncrement
        SConeDecrement

        LuminanceBaseline
        LuminanceIncrement20s80t
        LuminanceDecrement20s80t
        LuminanceIncrement10s80t
        LuminanceDecrement10s80t
        LuminanceIncrement5s80t
        LuminanceDecrement5s80t
        LuminanceIncrement3s80t
        LuminanceDecrement3s80t
        LuminanceChirp
        LuminanceSquarewave1


        Other  % For backwards compatibility
    end

    methods

        function n = frames(obj, truncate)
            % FRAMES
            %
            % Inputs:
            %   truncate    logical (default = true)
            %       Account for removal of 1st blank frame, lost end frames
            % -------------------------------------------------------------
            import ao.Stimuli;

            if nargin < 2
                truncate = true;
            end

            switch obj
                case Stimuli.LightsOn
                    n = 2000;
                case {Stimuli.ContrastDecrement20Long, Stimuli.BaselineLong}
                    n = 1800;
                case {Stimuli.SequentialBarDecrement4to12of16}
                    n = 2875;
                case {Stimuli.Melanopsin_22m_180t, Stimuli.Melanopsin_27m_180t}
                    n = 4500;
                case {Stimuli.IntensityIncrement10s80t, Stimuli.IntensityIncrement20s80t}
                    n = 2000;
                case {Stimuli.BaselineLongZeroMean, Stimuli.MovingBarN, Stimuli.MovingBarS, Stimuli.MovingBarW, Stimuli.MovingBarE}
                    n = 3100;
                case {Stimuli.IntensityIncrement1On4OffSquares4x4, Stimuli.IntensityIncrement1On4OffSquares4x4Baseline}
                    n = 3000;
                case {Stimuli.IntensityIncrement1On4OffSquares6x6}
                    n = 5500;
                % case {Stimuli.MovingBarCardinal20pix1v180t, Stimuli.MovingBarCardinal20pix3v180t, Stimuli.MovingBarDiagonal20pix1v180t, Stimuli.MovingBarFullCardinal20pix1v180t, MovingBarFullDiagonal20pix1v180t}
                %     n = 4500;
                otherwise
                    stimName = char(obj);
                    if contains(stimName, 'HorizontalDecrementIncrement')
                        n = 1990;
                    elseif contains(stimName, {'SpacedOutIntensityBars2pix', 'HorizontalIntensityBars'})
                        n = 1980;
                    elseif endsWith(stimName, 'c20s70t')
                        n = 1740;
                    elseif contains(stimName, 'DecrementIncrement')
                        n = 2250;
                    elseif contains(stimName, 'SpacedOutIntensity')
                        n = 2000;
                    elseif contains(stimName, 'MovingBar')
                        if contains(stimName, '180t')
                            n = 4500;
                        elseif contains(stimName, {'8pix', '15pix'})
                            n = 3500;
                        else
                            n = 2000;
                        end
                    elseif contains(stimName, 'Cone')
                        n = 4043;
                    elseif contains(stimName, 'TopticaSim')
                        n = 4500;
                    elseif contains(stimName, '80t')
                        if contains(stimName, '180t')
                            n = 4500;
                        elseif contains(stimName, 'Luminance')
                            n = 2040;
                        else
                            n = 2000;
                        end
                    elseif contains(stimName, '180t')
                        n = 4500;
                    else
                        n = 1500;
                    end
            end

            if truncate
                n = n - obj.lostEndFrames - 1;
            end
        end

        function n = lostEndFrames(obj)
            % LOSTENDFRAMES
            %
            % Description:
            %   Frames not saved from buffer at the end of trial
            %
            % -------------------------------------------------------------
            import ao.Stimuli;

            if obj == Stimuli.SequentialBarDecrement4to12of16
                n = 15;
            elseif contains(char(obj), 'DecrementIncrement')
                n = 10;
            else
                n = 20;
            end
        end

        function stim = trace(obj, truncate)
            import ao.Stimuli;

            if nargin < 2
                truncate = true;
            end

            stim = 0.5 * ones(1, obj.frames());

            stimName = char(obj);
            switch obj
                case Stimuli.IntensityIncrement1s80t
                    stim = zeros(1, obj.frames());
                    stim(501:525) = 1;
                case Stimuli.IntensityIncrement3s80t
                    stim = zeros(1, obj.frames());
                    stim(501:575) = 1;
                case Stimuli.IntensityIncrement5s80t
                    stim = zeros(1, obj.frames());
                    stim(501:625) = 1;
                case Stimuli.IntensityIncrement10s80t
                    stim = zeros(1, obj.frames());
                    stim(501:750) = 1;
                case Stimuli.IntensityIncrement20s80t
                    stim = zeros(1, obj.frames());
                    stim(501:1000) = 1;
                case Stimuli.IntensityIncrement80s180t
                    stim = zeros(1, obj.frames());
                    stim(501:2500) = 1;
                case Stimuli.ContrastIncrement20
                    stim(251:750) = 1;
                case Stimuli.ContrastDecrement20
                    stim(251:750) = 0;
                case Stimuli.ContrastIncrement10
                    stim(501:750) = 1;
                case Stimuli.ContrastDecrement10
                    stim(501:750) = 0;
                case Stimuli.ContrastIncrement5
                    stim(501:625) = 1;
                case Stimuli.ContrastDecrement5
                    stim(501:625) = 0;
                case Stimuli.ContrastIncrement3
                    stim(501:575) = 1;
                case Stimuli.ContrastDecrement3
                    stim(501:575) = 0;
                case Stimuli.ContrastIncrement20Long
                    stim(501:1001) = 1;
                case Stimuli.ContrastDecrement20Long
                    stim(501:1001) = 0;
                case Stimuli.ContrastDecrement20Half
                    stim(251:750) = 0.25;
                case Stimuli.ContrastDecrement10Half
                    stim(251:500) = 0.25;
                case {Stimuli.ContrastIncrement20s80t, Stimuli.LuminanceIncrement20s80t}
                    stim(501:1000) = 1;
                case {Stimuli.ContrastDecrement20s80t, Stimuli.LuminanceDecrement20s80t}
                    stim(501:1000) = 0;
                case Stimuli.TemporalSquarewave05
                    stim = Stimuli.getModulation(0.5, 1000, true);
                    stim = [0.5 * ones(1, 250), stim, 0.5 * ones(1, 250)];
                case {Stimuli.TemporalSquarewave1, Stimuli.LuminanceSquarewave1}
                    stim = Stimuli.getModulation(1, 1000, true);
                    stim = [0.5 * ones(1, 250), stim, 0.5 * ones(1, 250)];
                case Stimuli.TemporalContrastSquarewave05
                    stim = 0.5 * ones(1, 250);
                    stim = [stim, repmat([0.55 * ones(1, 25), 0.45 * ones(1, 25)], [1, 5])];
                    stim = [stim, repmat([0.625 * ones(1, 25), 0.375 * ones(1, 25)], [1, 5])];
                    stim = [stim, repmat([0.75 * ones(1, 25), 0.25 * ones(1, 25)], [1, 5])];
                    stim = [stim, repmat([ones(1, 25), zeros(1, 25)], [1, 5])];
                    stim = [stim, 0.5 * ones(1, 250)];
                case Stimuli.SequentialBarDecrement4to12of16
                    onFrames = 125; offFrames = 125;
                    for i = 1:9
                        stim(500 + ((i-1)*(onFrames+offFrames)) + 1:500+((i-1)*(onFrames+offFrames)) + onFrames) = 0;
                    end
                case {Stimuli.MovingBarS, Stimuli.MovingBarN, Stimuli.MovingBarE, Stimuli.MovingBarW}
                    stim = zeros(1, obj.frames());
                    stim(2:257) = 1:256;
                    stim(1032:1287) = 1:256;
                    stim(2062:2317) = 1:256;
                case Stimuli.ShortChirp
                    S = load('short_chirp.mat');
                    stim = S.shortChirp;
                case {Stimuli.Chirp, Stimuli.LuminanceChirp}
                    S = load('chirp.mat');
                    stim = S.chirp;
                case {Stimuli.MovingBarCardinal18pix1v180t, Stimuli.MovingBarDiagonal18pix1v180t}
                    stim = dlmread('trace_movingbars_18pix_1v_180t.txt'); %#ok<*DLMRD>
                case {Stimuli.MovingBarCardinal20pix1v180t, Stimuli.MovingBarCardinal20pix3v180t,...
                        Stimuli.MovingBarDiagonal20pix1v180t}
                    barTimes = [20, 60, 100, 140];
                    barTimes = 25 * (barTimes+1);
                    if contains(char(obj), '20pix')
                        barSize = 20;
                    else
                        barSize = 18;
                    end
                    if contains(char(obj), '3v180t')
                        barTrace = 1:3:(256+barSize);
                    else
                        barTrace = 1:(256+barSize);
                    end
                    for i  = 1:numel(barTimes)
                        stim(barTimes(i):barTimes(i)+numel(barTrace)-1) = barTrace;
                    end
                case {Stimuli.IntensityIncrement1On4OffSquares4x4, Stimuli.IntensityIncrement1On4OffSquares6x6}
                    preTime = 20; tailTime = 20; % sec
                    squareTime = 1; postSquareTime = 4;
                    if contains(char(obj), '4x4')
                        numSquares = 16;
                    elseif contains(char(obj), '6x6')
                        numSquares = 36;
                    end
                    totalTime = preTime + tailTime + numSquares * (squareTime + postSquareTime);
                    stim = zeros(1, totalTime*25);
                    startFrame = preTime * 25; % start at 20 sec
                    for i = 1:numSquares
                        startFrame = startFrame + 1;
                        stopFrame = startFrame + (squareTime*25);
                        stim(startFrame:stopFrame) = 1;
                        startFrame = 25*(squareTime+postSquareTime) + startFrame;
                    end
                case {Stimuli.IntensityIncrement1On4OffSquares4x4Baseline}
                    stim = zeros(1, obj.frames);
                otherwise
                    if contains(stimName, 'HorizontalDecrementIncrement')
                        stim(:, 251:750) = 0;
                        stim(:, 751:1250) = 1;
                    elseif contains(stimName, 'DecrementIncrement')
                        stim(:, 501:1000) = 0;
                        stim(:, 1001:1500) = 1;
                    elseif contains(stimName, {'IntensityBar10s', 'SpacedOutIntensity'})
                        stim = stim - 0.5;
                        stim(:, 501:750) = 1;
                    elseif ismember('MovingBar', stimName)
                        stim = dlmread('moving_bar_trace.txt');
                    elseif ismember('Bar', stimName)
                        % stim = 0.5 * ones(1, 1500);
                        stim(251:750) = 0;
                    elseif ismember('TemporalBinaryNoise', stimName)
                        noiseSeed = str2double(erase(char(obj), 'TemporalBinaryNoise'));
                        stim = Stimuli.getNoise(noiseSeed, true);
                    elseif ismember('TemporalNoise', stimName)
                        noiseSeed = str2double(erase(char(obj), 'TemporalNoise'));
                        stim = Stimuli.getNoise(noiseSeed, false);
                    elseif contains(stimName, 'c20s70t')
                        stimContrast = num2str(extractFlaggedNumber(str, 'c_'));
                        if contains(stimName, 'decrement')
                            stim(501:1000) = -stimContrast;
                        else
                            stim(501:1000) = stimContrast;
                        end
                    end
            end

            if truncate
                stim = stim(2:end-obj.lostEndFrames);
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
            % -------------------------------------------------------------
            import ao.Stimuli;

            if nargin < 2
                truncate = true;
            end

            switch obj
                case {Stimuli.Baseline, Stimuli.BaselineLong, Stimuli.BaselineLongZeroMean, Stimuli.BaselineZeroMean}
                    bkgd = [];
                case {Stimuli.Chirp, Stimuli.LuminanceChirp}
                    bkgd = [1 190];
                case {Stimuli.ContrastDecrement20Long, Stimuli.ContrastIncrement20Long, Stimuli.IntensityIncrement20s80t, Stimuli.IntensityIncrement10s80t, Stimuli.LightsOn}
                    % bkgd = [1 500];
                    bkgd = [150 498];
                case {Stimuli.ContrastDecrement20s80t, Stimuli.ContrastIncrement20s80t, Stimuli.ContrastDecrement10, Stimuli.ContrastDecrement5, Stimuli.ContrastDecrement3, Stimuli.ContrastIncrement10, Stimuli.ContrastIncrement5, Stimuli.ContrastIncrement3, Stimuli.SequentialBarDecrement4to12of16}
                    bkgd = [1 500];
                case {Stimuli.LuminanceDecrement20s80t, Stimuli.LuminanceIncrement20s80t, Stimuli.LuminanceDecrement10s80t, Stimuli.LuminanceIncrement10s80t}
                    bkgd = [1 745];
                case {Stimuli.Melanopsin_22m_180t, Stimuli.Melanopsin_27m_180t}
                    bkgd = [4000 4470];
                case {Stimuli.MovingBarN, Stimuli.MovingBarS, Stimuli.MovingBarW, Stimuli.MovingBarE}
                    bkgd = [2925 3079];
                otherwise
                    if contains(char(obj), 'Cone')
                        bkgd = [1850, 2250];
                    elseif contains(char(obj), 'MovingBar')
                        bkgd = [250 498]; % [1 500]
                    elseif contains(char(obj), 'TopticaSim')
                        bkgd = [3000 3200];
                    elseif contains(char(obj), 'DecrementIncrement') && ~contains(char(obj), 'Horizontal')
                        bkgd = [1 500];
                    elseif contains(char(obj), 'IntensityBar')
                        bkgd = [150 497];
                    elseif contains(char(obj), 'IntensityIncrement')
                        bkgd = [200 498];
                    elseif endsWith(char(obj), 'c20s70t')
                        bkgd = [250 498];
                    else
                        bkgd = [1 250];
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
            % -------------------------------------------------------------
            import ao.Stimuli;

            if nargin < 2
                truncate = true;
            end

            switch obj
                case {Stimuli.Baseline, Stimuli.BaselineZeroMean, Stimuli.BaselineLongZeroMean}
                    signal = [];
                case Stimuli.LightsOn
                    signal = [501 2250];
                case Stimuli.IntensityIncrement1s80t
                    signal = [501 525];
                case Stimuli.IntensityIncrement3s80t
                    signal = [501 575];
                case Stimuli.IntensityIncrement5s80t
                    signal = [501 625];
                case Stimuli.IntensityIncrement10s80t
                    signal = [501 750];
                case Stimuli.IntensityIncrement20s80t
                    signal = [501 1000];
                case Stimuli.IntensityIncrement80s180t
                    signal = [501 2500];
                case Stimuli.IntensityIncrement50c10s80t
                    signal = [501 750];
                case {Stimuli.ContrastIncrement20, Stimuli.ContrastDecrement20, Stimuli.ContrastDecrement20Half}
                    signal = [251 750];
                case {Stimuli.ContrastDecrement10a, Stimuli.ContrastDecrement10Half}
                    signal = [251 500];
                case {Stimuli.TemporalSquarewave05, Stimuli.TemporalSquarewave1, Stimuli.TemporalContrastSquarewave05}
                    signal = [251 1250];
                case {Stimuli.ContrastDecrement20Long, Stimuli.ContrastIncrement20Long}
                    signal = [501 1000];
                case {Stimuli.ContrastDecrement20s80t, Stimuli.ContrastIncrement20s80t, Stimuli.LuminanceDecrement20s80t, Stimuli.LuminanceIncrement20s80t}
                    signal = [501 1000];
                case {Stimuli.LuminanceDecrement20s80t, Stimuli.LuminanceIncrement20s80t}
                    signal = [750 1250];
                case {Stimuli.LuminanceDecrement10s80t, Stimuli.LuminanceIncrement10s80t}
                    signal = [750 1000];
                case {Stimuli.ContrastDecrement10, Stimuli.ContrastIncrement10}
                    signal = [501 750];
                case {Stimuli.ContrastDecrement5, Stimuli.ContrastIncrement5}
                    signal = [501 625];
                case {Stimuli.ContrastDecrement3, Stimuli.ContrastIncrement3}
                    signal = [501 575];
                case Stimuli.SequentialBarDecrement4to12of16
                    signal = [501 2625];
                case {Stimuli.Chirp, Stimuli.LuminanceChirp}
                    signal = [196 1315];
                otherwise
                    if contains(char(obj), 'DecrementIncrement')
                        if contains(char(obj), 'Horizontal')
                            signal = [250 1250];
                        else
                            signal = [500 1500];
                        end
                    elseif contains(char(obj), {'Decrement20', 'Increment20'}) && ~contains(char(obj), '20s')
                        signal = [251 750];
                    elseif endsWith(char(obj), 'c20s70t')
                        signal = [501 1000];
                    elseif contains(char(obj), 'IntensityBar')
                        signal = [501 750];
                    elseif contains(char(obj), 'Bar')
                        signal = [251 750];
                    elseif contains(char(obj), 'Cone')
                        signal = [2270 2770];
                    elseif contains(char(obj), 'TopticaSim')
                        signal = [3250, 3750];
                    elseif contains(char(obj), 'TemporalNoise') || contains(char(obj), 'TemporalBinaryNoise')
                        signal = [251 1375];
                    end
            end

            if truncate
                signal = signal - 1;
            end
        end

        function app = openRoiAverageView(obj, epochGroup)
            % OPENROIAVERAGEVIEW  Open UI with stimulus-specific defaults
            import ao.Stimuli;

            epochIDs = epochGroup.stim{epochGroup.stim.Stimulus == obj, 4};
            epochIDs = epochIDs{1};

            titleStr = [char(epochGroup.experimentDate), ' ', char(obj)];

            switch obj
                case {Stimuli.ContrastDecrement20, Stimuli.ContrastIncrement20, Stimuli.ContrastDecrement10Half, Stimuli.ContrastDecrement20Half, Stimuli.ContrastDecrement20Long, Stimuli.ContrastIncrement20Long, Stimuli.ContrastIncrement20s80t, Stimuli.ContrastDecrement20s80t, Stimuli.ContrastDecrement10, Stimuli.ContrastDecrement5, Stimuli.ContrastDecrement3}
                    app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                        obj.signal, titleStr);
                case {Stimuli.LuminanceIncrement20s80t, Stimuli.LuminanceDecrement20s80t, Stimuli.LuminanceIncrement10s80t, Stimuli.LuminanceDecrement10s80t}
                    app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                        obj.signal, titleStr);
                case {Stimuli.Baseline, Stimuli.BaselineLong, Stimuli.LuminanceBaseline, Stimuli.BaselineLongZeroMean}
                    app = RoiAverageView(epochGroup, epochIDs, [1 1000],...
                        [], titleStr);
                case {Stimuli.TemporalSquarewave05, Stimuli.TemporalSquarewave1, Stimuli.LuminanceSquarewave1, Stimuli.TemporalContrastSquarewave05}
                    app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                        [], titleStr, obj.trace(true));
                case {Stimuli.Chirp, Stimuli.ShortChirp, Stimuli.LuminanceChirp}
                    app = RoiAverageView(epochGroup, epochIDs, obj.bkgd,...
                         [], titleStr, obj.trace(true));
                case Stimuli.SequentialBarDecrement4to12of16
                    app = RoiAverageView(epochGroup, epochIDs, obj.bkgd,...
                        [], titleStr, obj.trace);
                case {Stimuli.TemporalNoise11, Stimuli.TemporalNoise16, Stimuli.TemporalNoise20, Stimuli.TemporalNoise35, Stimuli.TemporalNoise42}
                    app = RoiAverageView(epochGroup, epochIDs, obj.bkgd,...
                        obj.signal, titleStr);
                case {Stimuli.Baseline50p70s}
                    app = RoiAverageView2(epochGroup, epochIDs, [], [], titleStr);
                otherwise
                    if contains(char(obj), 'DecrementIncrement')
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                            obj.signal, titleStr, obj.trace(true));
                    elseif contains(char(obj), 'MovingBar')
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                            [], titleStr, obj.trace(true));
                    elseif ismember('Bar', char(obj))
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                            obj.signal, titleStr);
                    elseif contains(char(obj), 'Cone')
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd,...
                            obj.signal, titleStr);
                    elseif contains(char(obj), {'TopticaSim', 'IntensityIncrement', 'LightsOn'})
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd, obj.signal, titleStr);
                    elseif endsWith(char(obj), 'c20s70t')
                        app = RoiAverageView2(epochGroup, epochIDs, obj.bkgd, obj.signal, titleStr);
                    else
                        warning('Stimulus not yet implemented')
                        return;
                    end
            end
        end

        function tf = isNoise(obj)
            import ao.Stimuli;

            if contains(char(obj), 'Noise')
                tf = true;
            else
                tf = false;
            end
        end

        function tf = isBaseline(obj)
            if contains(char(obj), 'Baseline')
                tf = true;
            else
                tf = false;
            end
        end
    end

    methods
        function makeMultiplot(obj, dataset, roiID, varargin)

            if ~isnumeric(roiID)
                roiID = dataset.uid2roi(roiID);
            end

            ip = inputParser();
            addParameter(ip, 'AvgOnly', true, @islogical);
            addParameter(ip, 'Method', 'dff', @ischar);
            addParameter(ip, 'Color', [], @isnumeric);
            addParameter(ip, 'Parent', [], @ishandle);
            addParameter(ip, 'LineWidth', 1.25, @isnumeric);
            parse(ip, varargin{:});

            avgOnly = ip.Results.AvgOnly;
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
            end


            stimName = lower(char(obj));
            [signals, xpts] = dataset.getStimulusResponses(char(obj), obj.bkgd, ...
                'Method', ip.Results.Method, 'Smooth', 100);
            if ndims(signals) == 3
                signals = signals(roiID, :, :);
                avgSignal = mean(signals,3);
            else
                signals = signals(roiID,:);
                avgSignal = signals;
            end

        end
    end

    methods (Static)
        function obj = init(str)
            % INIT  Initialize object from stimulus name
            import ao.Stimuli;

            try
                obj = Stimuli.(str);
                return
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
                case 'zero_mean_bkgd'
                    obj = Stimuli.BaselineZeroMean;
                case {'baseline_nostim_155', '155_background_256', 'temporal_contrast_bkgd'}
                    obj = Stimuli.Baseline;
                case 'temporal_contrast_bkgd_long'
                    obj = Stimuli.BaselineLong;
                case 'temporal_contrast_bkgd_70s'
                    obj = Stimuli.Baseline50p70s;
                case 'zero_mean_bkgd_long'
                    obj = Stimuli.BaselineLongZeroMean;
                case 'lights_on_toptica'
                    obj = Stimuli.LightsOn;

                case 'zero_mean_increment_1s_80t'
                    obj = Stimuli.IntensityIncrement1s80t;
                case 'zero_mean_increment_3s_80t'
                    obj = Stimuli.IntensityIncrement3s80t;
                case 'zero_mean_increment_5s_80t'
                    obj = Stimuli.IntensityIncrement5s80t;
                case {'zero_mean_increment_10s', 'zero_mean_increment_10s_80t'}
                    obj = Stimuli.IntensityIncrement10s80t;
                case 'zero_mean_increment_20s'
                    obj = Stimuli.IntensityIncrement20s80t;
                case 'intensity_increment_80s_180t'
                    obj = Stimuli.IntensityIncrement80s180t;
                case 'zero_mean_increment_50c_10s'
                    obj = Stimuli.IntensityIncrement50c10s80t;
                case {'20s_contrast_increment', 'temporal_contrast_increment_20s', 'temporal_contrast_inc_20s'}
                    obj = Stimuli.ContrastIncrement20;
                case {'20s_contrast_decrement', 'temporal_contrast_decrement_20s', 'temporal_contrast_dec_20s'}
                    obj = Stimuli.ContrastDecrement20;
                case 'temporal_contrast_decinc_20s_90t'
                    obj = Stimuli.ContrastDecrementIncrement20s90t;
                case '20s_contrast_increment_half'
                    obj = Stimuli.ContrastIncrement20Half;
                case '20s_contrast_decrement_half'
                    obj = Stimuli.ContrastDecrement20Half;
                case '20s_contrast_increment_quarter'
                    obj = Stimuli.ContrastIncrement20Quarter;
                case '20s_contrast_decrement_quarter'
                    obj = Stimuli.ContrastDecrement20Quarter;

                case 'contrast_increment_50c_20s_70t'
                    obj = Stimuli.ContrastIncrement50c20s70t;
                case 'contrast_decrement_50c_20s_70t'
                    obj = Stimuli.ContrastDecrement50c20s70t;
                case 'contrast_increment_75c_20s_70t'
                    obj = Stimuli.ContrastIncrement50c20s70t;
                case 'contrast_decrement_75c_20s_70t'
                    obj = Stimuli.ContrastDecrement50c20s70t;
                case 'contrast_increment_100c_20s_70t'
                    obj = Stimuli.ContrastIncrement100c20s70t;
                case 'contrast_decrement_100c_20s_70t'
                    obj = Stimuli.ContrastDecrement100c20s70t;

                case 'temporal_contrast_dec_10s'
                    obj = Stimuli.ContrastDecrement10;
                case 'temporal_contrast_dec_5s'
                    obj = Stimuli.ContrastDecrement5;
                case 'temporal_contrast_dec_3s'
                    obj = Stimuli.ContrastDecrement3;
                case 'temporal_contrast_inc_20s_80t'
                    obj = Stimuli.ContrastIncrement20s80t;
                case 'temporal_contrast_dec_20s_80t'
                    obj = Stimuli.ContrastDecrement20s80t;
                case 'temporal_contrast_dec_20s_long'
                    obj = Stimuli.ContrastDecrement20Long;
                case 'temporal_contrast_inc_20s_long'
                    obj = Stimuli.ContrastIncrement20Long;
                case '10s_contrast_decrement_half'
                    obj = Stimuli.ContrastDecrement10Half;
                case '10s_contrast_decrement'
                    obj = Stimuli.ContrastDecrement10a;
                case '10s_contrast_increment'
                    obj = Stimuli.ContrastIncrement10a;
                case 'temporal_squarewave_05hz'
                    obj = Stimuli.TemporalSquarewave05;
                case 'temporal_squarewave_1hz'
                    obj = Stimuli.TemporalSquarewave1;
                case 'temporal_contrast_squarewave_05hz'
                    obj = Stimuli.TemporalContrastSquarewave05;
                case 'chirp'
                    obj = Stimuli.Chirp;
                case 'chirp2'
                    obj = Stimuli.ShortChirp;
                case 'temporal_noise_11'
                    obj = Stimuli.TemporalNoise11;
                case 'temporal_noise_16'
                    obj = Stimuli.TemporalNoise16;
                case 'temporal_noise_20'
                    obj = Stimuli.TemporalNoise20;
                case 'temporal_noise_35'
                    obj = Stimuli.TemporalNoise35;
                case 'temporal_noise_42'
                    obj = Stimuli.TemporalNoise42;
                case 'temporal_binary_noise_11'
                    obj = Stimuli.TemporalBinaryNoise11;
                case 'temporal_binary_noise_16'
                    obj = Stimuli.TemporalBinaryNoise16;
                case 'temporal_binary_noise_20'
                    obj = Stimuli.TemporalBinaryNoise20;
                case 'temporal_binary_noise_35'
                    obj = Stimuli.TemporalBinaryNoise35;
                case 'temporal_binary_noise_42'
                    obj = Stimuli.TemporalBinaryNoise42;
                case 'sequential_bar_dec_4_to_12_of_16'
                    obj = Stimuli.SequentialBarDecrement4to12of16;
                case 'bar_decrement_1_of_16'
                    obj = Stimuli.Bar1of16;
                case 'bar_decrement_2_of_16'
                    obj = Stimuli.Bar2of16;
                case 'bar_decrement_3_of_16'
                    obj = Stimuli.Bar3of16;
                case 'bar_decrement_4_of_16'
                    obj = Stimuli.Bar4of16;
                case 'bar_decrement_5_of_16'
                    obj = Stimuli.Bar5of16;
                case 'bar_decrement_6_of_16'
                    obj = Stimuli.Bar6of16;
                case 'bar_decrement_7_of_16'
                    obj = Stimuli.Bar7of16;
                case 'bar_decrement_8_of_16'
                    obj = Stimuli.Bar8of16;
                case 'bar_decrement_9_of_16'
                    obj = Stimuli.Bar9of16;
                case 'bar_decrement_10_of_16'
                    obj = Stimuli.Bar10of16;
                case 'bar_decrement_11_of_16'
                    obj = Stimuli.Bar11of16;
                case 'bar_decrement_12_of_16'
                    obj = Stimuli.Bar12of16;
                case 'bar_decrement_13_of_16'
                    obj = Stimuli.Bar13of16;
                case 'bar_decrement_14_of_16'
                    obj = Stimuli.Bar14of16;
                case 'bar_decrement_15_of_16'
                    obj = Stimuli.Bar15of16;
                case 'bar_decrement_5_of_32'
                    obj = Stimuli.Bar5of32;
                case 'bar_decrement_6_of_32'
                    obj = Stimuli.Bar6of32;
                case 'bar_decrement_7_of_32'
                    obj = Stimuli.Bar7of32;
                case 'bar_decrement_8_of_32'
                    obj = Stimuli.Bar8of32;
                case 'bar_decrement_9_of_32'
                    obj = Stimuli.Bar9of32;
                case 'bar_decrement_10_of_32'
                    obj = Stimuli.Bar10of32;
                case 'bar_decrement_11_of_32'
                    obj = Stimuli.Bar11of32;
                case 'bar_decrement_12_of_32'
                    obj = Stimuli.Bar12of16;
                case 'bar_decrement_13_of_32'
                    obj = Stimuli.Bar13of32;
                case 'bar_decrement_14_of_32'
                    obj = Stimuli.Bar14of32;
                case 'bar_decrement_15_of_32'
                    obj = Stimuli.Bar15of32;
                case 'bar_decrement_16_of_32'
                    obj = Stimuli.Bar16of32;
                case 'bar_decrement_17_of_32'
                    obj = Stimuli.Bar17of32;
                case 'bar_decrement_18_of_32'
                    obj = Stimuli.Bar18of32;
                case 'bar_decrement_19_of_32'
                    obj = Stimuli.Bar19of32;
                case 'bar_decrement_20_of_32'
                    obj = Stimuli.Bar20of32;
                case 'bar_decrement_21_of_32'
                    obj = Stimuli.Bar21of32;
                case 'bar_decrement_22_of_32'
                    obj = Stimuli.Bar22of32;
                case 'bar_decrement_23_of_32'
                    obj = Stimuli.Bar23of32;
                case 'bar_decrement_24_of_32'
                    obj = Stimuli.Bar24of32;
                case 'bar_decrement_25_of_32'
                    obj = Stimuli.Bar25of32;
                case 'bar_decrement_26_of_32'
                    obj = Stimuli.Bar26of32;
                case 'bar_decrement_27_of_32'
                    obj = Stimuli.Bar27of32;
                case 'bar_decrement_28_of_32'
                    obj = Stimuli.Bar28of32;
                 case 'bar_decrement_1_of_8'
                    obj = Stimuli.Bar1of8;
                case 'bar_decrement_2_of_8'
                    obj = Stimuli.Bar2of8;
                case 'bar_decrement_3_of_8'
                    obj = Stimuli.Bar3of8;
                case 'bar_decrement_4_of_8'
                    obj = Stimuli.Bar4of8;
                case 'bar_decrement_5_of_8'
                    obj = Stimuli.Bar5of8;
                case 'bar_decrement_6_of_8'
                    obj = Stimuli.Bar6of8;
                case 'bar_decrement_7_of_8'
                    obj = Stimuli.Bar7of8;
                case 'bar_decrement_8_of_8'
                    obj = Stimuli.Bar8of8;
                 case 'horizontal_bar_decrement_1_of_8'
                    obj = Stimuli.HorizontalBar1of8;
                 case 'horizontal_bar_decrement_2_of_8'
                    obj = Stimuli.HorizontalBar2of8;
                 case 'horizontal_bar_decrement_3_of_8'
                    obj = Stimuli.HorizontalBar3of8;
                 case 'horizontal_bar_decrement_4_of_8'
                    obj = Stimuli.HorizontalBar4of8;
                 case 'horizontal_bar_decrement_5_of_8'
                    obj = Stimuli.HorizontalBar5of8;
                 case 'horizontal_bar_decrement_6_of_8'
                    obj = Stimuli.HorizontalBar6of8;
                 case 'horizontal_bar_decrement_7_of_8'
                    obj = Stimuli.HorizontalBar7of8;
                 case 'horizontal_bar_decrement_8_of_8'
                    obj = Stimuli.HorizontalBar8of8;
                 case 'spaced_out_bars_1_of_8'
                    obj = Stimuli.SpacedOutBars1of8;
                case 'spaced_out_bars_2_of_8'
                    obj = Stimuli.SpacedOutBars2of8;
                case 'spaced_out_bars_3_of_8'
                    obj = Stimuli.SpacedOutBars3of8;
                case 'spaced_out_bars_4_of_8'
                    obj = Stimuli.SpacedOutBars4of8;
                case 'spaced_out_bars_5_of_8'
                    obj = Stimuli.SpacedOutBars5of8;
                case 'spaced_out_bars_6_of_8'
                    obj = Stimuli.SpacedOutBars6of8;
                case 'spaced_out_bars_7_of_8'
                    obj = Stimuli.SpacedOutBars7of8;
                case 'spaced_out_bars_8_of_8'
                    obj = Stimuli.SpacedOutBars8of8;
                case 'spaced_out_bars_1_of_7'
                    obj = Stimuli.SpacedOutBars1of7;
                case 'spaced_out_bars_2_of_7'
                    obj = Stimuli.SpacedOutBars2of7;
                case 'spaced_out_bars_3_of_7'
                    obj = Stimuli.SpacedOutBars3of7;
                case 'spaced_out_bars_4_of_7'
                    obj = Stimuli.SpacedOutBars4of7;
                case 'spaced_out_bars_5_of_7'
                    obj = Stimuli.SpacedOutBars5of7;
                case 'spaced_out_bars_6_of_7'
                    obj = Stimuli.SpacedOutBars6of7;
                case 'spaced_out_bars_7_of_7'
                    obj = Stimuli.SpacedOutBars7of7;
                case 'spaced_out_bars_1_of_4'
                    obj = Stimuli.SpacedOutBars1of4;
                case 'spaced_out_bars_2_of_4'
                    obj = Stimuli.SpacedOutBars2of4;
                case 'spaced_out_bars_3_of_4'
                    obj = Stimuli.SpacedOutBars3of4;
                case 'spaced_out_bars_4_of_4'
                    obj = Stimuli.SpacedOutBars4of4;
                case 'spaced_out_vert_bars_1_of_4'
                    obj = Stimuli.SpacedOutVerticalBars1of4;
                case 'spaced_out_vert_bars_2_of_4'
                    obj = Stimuli.SpacedOutVerticalBars2of4;
                case 'spaced_out_vert_bars_3_of_4'
                    obj = Stimuli.SpacedOutVerticalBars3of4;
                case 'spaced_out_vert_bars_4_of_4'
                    obj = Stimuli.SpacedOutVerticalBars4of4;
                case 'spaced_out_inc_bars_1_of_7'
                    obj = Stimuli.SpacedOutIncrementBars1of7;
                case 'spaced_out_inc_bars_2_of_7'
                    obj = Stimuli.SpacedOutIncrementBars2of7;
                case 'spaced_out_inc_bars_3_of_7'
                    obj = Stimuli.SpacedOutIncrementBars3of7;
                case 'spaced_out_inc_bars_4_of_7'
                    obj = Stimuli.SpacedOutIncrementBars4of7;
                case 'spaced_out_inc_bars_5_of_7'
                    obj = Stimuli.SpacedOutIncrementBars5of7;
                case 'spaced_out_inc_bars_6_of_7'
                    obj = Stimuli.SpacedOutIncrementBars6of7;
                case 'spaced_out_inc_bars_7_of_7'
                    obj = Stimuli.SpacedOutIncrementBars7of7;
                case 'spaced_out_decinc_bars_1_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars1of7;
                case 'spaced_out_decinc_bars_2_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars2of7;
                case 'spaced_out_decinc_bars_3_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3of7;
                case 'spaced_out_decinc_bars_4_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars4of7;
                case 'spaced_out_decinc_bars_5_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars5of7;
                case 'spaced_out_decinc_bars_6_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars6of7;
                case 'spaced_out_decinc_bars_7_of_7'
                    obj = Stimuli.SpacedOutDecrementIncrementBars7of7;
                case 'spaced_out_decinc_bars_3pix_1_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix1of9;
                case 'spaced_out_decinc_bars_3pix_2_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix2of9;
                case 'spaced_out_decinc_bars_3pix_3_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix3of9;
                case 'spaced_out_decinc_bars_3pix_4_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix4of9;
                case 'spaced_out_decinc_bars_3pix_5_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix5of9;
                case 'spaced_out_decinc_bars_3pix_6_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix6of9;
                case 'spaced_out_decinc_bars_3pix_7_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix7of9;
                case 'spaced_out_decinc_bars_3pix_8_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix8of9;
                case 'spaced_out_decinc_bars_3pix_9_of_9'
                    obj = Stimuli.SpacedOutDecrementIncrementBars3pix9of9;
                case 'spacedout_int_bars_1_of_9'
                    obj = Stimuli.SpacedOutIntensityBars1of9;
                case 'spacedout_int_bars_2_of_9'
                    obj = Stimuli.SpacedOutIntensityBars2of9;
                case 'spacedout_int_bars_3_of_9'
                    obj = Stimuli.SpacedOutIntensityBars3of9;
                case 'spacedout_int_bars_4_of_9'
                    obj = Stimuli.SpacedOutIntensityBars4of9;
                case 'spacedout_int_bars_5_of_9'
                    obj = Stimuli.SpacedOutIntensityBars5of9;
                case 'spacedout_int_bars_6_of_9'
                    obj = Stimuli.SpacedOutIntensityBars6of9;
                case 'spacedout_int_bars_7_of_9'
                    obj = Stimuli.SpacedOutIntensityBars7of9;
                case 'spacedout_int_bars_8_of_9'
                    obj = Stimuli.SpacedOutIntensityBars8of9;
                case 'spacedout_int_bars_9_of_9'
                    obj = Stimuli.SpacedOutIntensityBars9of9;
                case 'spacedout_int_bars_25i_1_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i1of9;
                case 'spacedout_int_bars_25i_2_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i2of9;
                case 'spacedout_int_bars_25i_3_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i3of9;
                case 'spacedout_int_bars_25i_4_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i4of9;
                case 'spacedout_int_bars_25i_5_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i5of9;
                case 'spacedout_int_bars_25i_6_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i6of9;
                case 'spacedout_int_bars_25i_7_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i7of9;
                case 'spacedout_int_bars_25i_8_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i8of9;
                case 'spacedout_int_bars_25i_9_of_9'
                    obj = Stimuli.SpacedOutIntensityBars25i9of9;
                case 'spaced_out_int_bars_2pix_7_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix7of32;
                case 'spaced_out_int_bars_2pix_8_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix8of32;
                case 'spaced_out_int_bars_2pix_9_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix9of32;
                case 'spaced_out_int_bars_2pix_10_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix10of32;
                case 'spaced_out_int_bars_2pix_11_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix11of32;
                case 'spaced_out_int_bars_2pix_12_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix12of32;
                case 'spaced_out_int_bars_2pix_13_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix13of32;
                case 'spaced_out_int_bars_2pix_14_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix14of32;
                case 'spaced_out_int_bars_2pix_15_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix15of32;
                case 'spaced_out_int_bars_2pix_16_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix16of32;
                case 'spaced_out_int_bars_2pix_17_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix17of32;
                case 'spaced_out_int_bars_2pix_18_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix18of32;
                case 'spaced_out_int_bars_2pix_19_of_32'
                    obj = Stimuli.SpacedOutIntensityBars2pix19of32;
                case 'mod_bar_4_of_32'
                    obj = Stimuli.DecrementIncrementBar4of32;
                case 'mod_bar_5_of_32'
                    obj = Stimuli.DecrementIncrementBar5of32;
                case 'mod_bar_6_of_32'
                    obj = Stimuli.DecrementIncrementBar6of32;
                case 'mod_bar_7_of_32'
                    obj = Stimuli.DecrementIncrementBar7of32;
                case 'mod_bar_8_of_32'
                    obj = Stimuli.DecrementIncrementBar8of32;
                case 'mod_bar_9_of_32'
                    obj = Stimuli.DecrementIncrementBar9of32;
                case 'mod_bar_10_of_32'
                    obj = Stimuli.DecrementIncrementBar10of32;
                case 'mod_bar_11_of_32'
                    obj = Stimuli.DecrementIncrementBar11of32;
                case 'mod_bar_12_of_32'
                    obj = Stimuli.DecrementIncrementBar12of32;
                case 'mod_bar_13_of_32'
                    obj = Stimuli.DecrementIncrementBar13of32;
                case 'mod_bar_14_of_32'
                    obj = Stimuli.DecrementIncrementBar14of32;
                case 'mod_bar_15_of_32'
                    obj = Stimuli.DecrementIncrementBar15of32;
                case 'mod_bar_16_of_32'
                    obj = Stimuli.DecrementIncrementBar16of32;
                case 'mod_bar_17_of_32'
                    obj = Stimuli.DecrementIncrementBar17of32;
                case 'mod_bar_18_of_32'
                    obj = Stimuli.DecrementIncrementBar18of32;
                case 'mod_bar_19_of_32'
                    obj = Stimuli.DecrementIncrementBar19of32;
                case 'mod_bar_20_of_32'
                    obj = Stimuli.DecrementIncrementBar20of32;
                case 'mod_bar_21_of_32'
                    obj = Stimuli.DecrementIncrementBar21of32;
                case 'mod_bar_22_of_32'
                    obj = Stimuli.DecrementIncrementBar22of32;
                case 'mod_bar_23_of_32'
                    obj = Stimuli.DecrementIncrementBar23of32;
                case 'mod_bar_24_of_32'
                    obj = Stimuli.DecrementIncrementBar24of32;
                case 'mod_bar_25_of_32'
                    obj = Stimuli.DecrementIncrementBar25of32;
                case 'mod_bar_26_of_32'
                    obj = Stimuli.DecrementIncrementBar26of32;
                case 'mod_bar_27_of_32'
                    obj = Stimuli.DecrementIncrementBar27of32;
                case 'mod_bar_28_of_32'
                    obj = Stimuli.DecrementIncrementBar28of32;
                case 'mod_bar_29_of_32'
                    obj = Stimuli.DecrementIncrementBar29of32;
                case 'mod_bar_30_of_32'
                    obj = Stimuli.DecrementIncrementBar30of32;
                case 'intensity_bar_10_of_32'
                    obj = Stimuli.IntensityBar10s10of32;
                case 'bar_intensity_10s_11_of_32'
                    obj = Stimuli.IntensityBar10s11of32;
                case 'bar_intensity_10s_12_of_32'
                    obj = Stimuli.IntensityBar10s12of32;
                case 'bar_intensity_10s_13_of_32'
                    obj = Stimuli.IntensityBar10s13of32;
                case 'intensity_bar_15_of_32'
                    obj = Stimuli.IntensityBar10s15of32;
                case 'intensity_bar_20_of_32'
                    obj = Stimuli.IntensityBar10s20of32;
                case 'intensity_bar_25_of_32'
                    obj = Stimuli.IntensityBar10s25of32;
                case 'intensity_bar_30_of_32'
                    obj = Stimuli.IntensityBar10s30of32;
                case 'bar_intensity_10s_50c_1_of_32'
                    obj = Stimuli.IntensityBar10s50c80t1of32;
                case 'bar_intensity_10s_50c_2_of_32'
                    obj = Stimuli.IntensityBar10s50c80t2of32;
                case 'bar_intensity_10s_50c_3_of_32'
                    obj = Stimuli.IntensityBar10s50c80t3of32;
                case 'bar_intensity_10s_50c_4_of_32'
                    obj = Stimuli.IntensityBar10s50c80t4of32;
                case 'bar_intensity_10s_50c_5_of_32'
                    obj = Stimuli.IntensityBar10s50c80t5of32;
                case 'bar_intensity_10s_50c_6_of_32'
                    obj = Stimuli.IntensityBar10s50c80t6of32;
                case 'bar_intensity_10s_50c_7_of_32'
                    obj = Stimuli.IntensityBar10s50c80t7of32;
                case 'bar_intensity_10s_50c_8_of_32'
                    obj = Stimuli.IntensityBar10s50c80t8of32;
                case 'bar_intensity_10s_50c_9_of_32'
                    obj = Stimuli.IntensityBar10s50c80t9of32;
                case 'bar_intensity_10s_50c_10_of_32'
                    obj = Stimuli.IntensityBar10s50c80t10of32;
                case 'bar_intensity_10s_50c_11_of_32'
                    obj = Stimuli.IntensityBar10s50c80t11of32;
                case 'bar_intensity_10s_50c_12_of_32'
                    obj = Stimuli.IntensityBar10s50c80t12of32;
                case 'bar_intensity_10s_50c_13_of_32'
                    obj = Stimuli.IntensityBar10s50c80t13of32;
                case 'bar_intensity_10s_50c_14_of_32'
                    obj = Stimuli.IntensityBar10s50c80t14of32;
                case 'bar_intensity_10s_50c_15_of_32'
                    obj = Stimuli.IntensityBar10s50c80t15of32;
                case 'bar_intensity_10s_50c_16_of_32'
                    obj = Stimuli.IntensityBar10s50c80t16of32;
                case 'bar_intensity_10s_50c_17_of_32'
                    obj = Stimuli.IntensityBar10s50c80t17of32;
                case 'bar_intensity_10s_50c_18_of_32'
                    obj = Stimuli.IntensityBar10s50c80t18of32;
                case 'bar_intensity_10s_50c_19_of_32'
                    obj = Stimuli.IntensityBar10s50c80t19of32;
                case 'bar_intensity_10s_50c_20_of_32'
                    obj = Stimuli.IntensityBar10s50c80t20of32;
                case 'bar_intensity_10s_50c_21_of_32'
                    obj = Stimuli.IntensityBar10s50c80t21of32;
                case 'bar_intensity_10s_50c_22_of_32'
                    obj = Stimuli.IntensityBar10s50c80t22of32;
                case 'bar_intensity_10s_50c_23_of_32'
                    obj = Stimuli.IntensityBar10s50c80t23of32;
                case 'bar_intensity_10s_50c_24_of_32'
                    obj = Stimuli.IntensityBar10s50c80t24of32;
                case 'bar_intensity_10s_50c_25_of_32'
                    obj = Stimuli.IntensityBar10s50c80t25of32;
                case 'bar_intensity_10s_50c_26_of_32'
                    obj = Stimuli.IntensityBar10s50c80t26of32;
                case 'bar_intensity_10s_50c_27_of_32'
                    obj = Stimuli.IntensityBar10s50c80t27of32;
                case 'bar_intensity_10s_50c_28_of_32'
                    obj = Stimuli.IntensityBar10s50c80t28of32;
                case 'bar_intensity_10s_50c_29_of_32'
                    obj = Stimuli.IntensityBar10s50c80t29of32;
                case 'bar_intensity_10s_50c_30_of_32'
                    obj = Stimuli.IntensityBar10s50c80t30of32;
                case 'bar_intensity_10s_50c_31_of_32'
                    obj = Stimuli.IntensityBar10s50c80t31of32;
                % 32 series of horizontal intensity bars
                case 'horizontal_intensity_bar_7_of_32'
                    obj = Stimuli.HorizontalIntensityBar7of32;
                case 'horizontal_intensity_bar_8_of_32'
                    obj = Stimuli.HorizontalIntensityBar8of32;
                case 'horizontal_intensity_bar_9_of_32'
                    obj = Stimuli.HorizontalIntensityBar9of32;
                case 'horizontal_intensity_bar_10_of_32'
                    obj = Stimuli.HorizontalIntensityBar10of32;
                case 'horizontal_intensity_bar_11_of_32'
                    obj = Stimuli.HorizontalIntensityBar11of32;
                case 'horizontal_intensity_bar_12_of_32'
                    obj = Stimuli.HorizontalIntensityBar12of32;
                case 'horizontal_intensity_bar_13_of_32'
                    obj = Stimuli.HorizontalIntensityBar13of32;
                case 'horizontal_intensity_bar_14_of_32'
                    obj = Stimuli.HorizontalIntensityBar14of32;
                case 'horizontal_intensity_bar_15_of_32'
                    obj = Stimuli.HorizontalIntensityBar15of32;
                case 'horizontal_intensity_bar_16_of_32'
                    obj = Stimuli.HorizontalIntensityBar16of32;
                case 'horizontal_intensity_bar_17_of_32'
                    obj = Stimuli.HorizontalIntensityBar17of32;
                case 'horizontal_intensity_bar_18_of_32'
                    obj = Stimuli.HorizontalIntensityBar18of32;
                case 'horizontal_intensity_bar_19_of_32'
                    obj = Stimuli.HorizontalIntensityBar19of32;
                case 'horizontal_intensity_bar_20_of_32'
                    obj = Stimuli.HorizontalIntensityBar20of32;
                case 'horizontal_intensity_bar_21_of_32'
                    obj = Stimuli.HorizontalIntensityBar21of32;
                case 'horizontal_intensity_bar_22_of_32'
                    obj = Stimuli.HorizontalIntensityBar22of32;
                case 'horizontal_intensity_bar_23_of_32'
                    obj = Stimuli.HorizontalIntensityBar23of32;
                case 'horizontal_intensity_bar_24_of_32'
                    obj = Stimuli.HorizontalIntensityBar24of32;
                case 'horizontal_intensity_bar_25_of_32'
                    obj = Stimuli.HorizontalIntensityBar25of32;
                case 'horizontal_intensity_bar_26_of_32'
                    obj = Stimuli.HorizontalIntensityBar26of32;
                case 'horizontal_intensity_bar_27_of_32'
                    obj = Stimuli.HorizontalIntensityBar27of32;
                % 64 series of horizontal intensity bars
                case 'horizontal_intensity_bar_39_of_64'
                    obj = Stimuli.HorizontalIntensityBar39of64;
                case 'horizontal_intensity_bar_40_of_64'
                    obj = Stimuli.HorizontalIntensityBar40of64;
                % 32 series of horizontal dec/inc bars
                case {'horizontal_decinc_bar_8_of_32', 'horizontal_bar_decinc_8_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar8of32;
                case {'horizontal_decinc_bar_9_of_32', 'horizontal_bar_decinc_9_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar9of32;
                case {'horizontal_decinc_bar_10_of_32', 'horizontal_bar_decinc_10_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar10of32;
                case {'horizontal_decinc_bar_11_of_32', 'horizontal_bar_decinc_11_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar11of32;
                case {'horizontal_decinc_bar_12_of_32', 'horizontal_bar_decinc_12_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar12of32;
                case {'horizontal_decinc_bar_13_of_32', 'horizontal_bar_decinc_13_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar13of32;
                case {'horizontal_decinc_bar_14_of_32', 'horizontal_bar_decinc_14_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar14of32;
                case {'horizontal_decinc_bar_15_of_32', 'horizontal_bar_decinc_15_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar15of32;
                case {'horizontal_decinc_bar_16_of_32', 'horizontal_bar_decinc_16_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar16of32;
                case {'horizontal_decinc_bar_17_of_32', 'horizontal_bar_decinc_17_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar17of32;
                case {'horizontal_decinc_bar_18_of_32', 'horizontal_bar_decinc_18_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar18of32;
                case {'horizontal_decinc_bar_19_of_32', 'horizontal_bar_decinc_19_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar19of32;
                case {'horizontal_decinc_bar_20_of_32', 'horizontal_bar_decinc_20_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar20of32;
                case {'horizontal_decinc_bar_21_of_32', 'horizontal_bar_decinc_21_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar21of32;
                case {'horizontal_decinc_bar_22_of_32', 'horizontal_bar_decinc_22_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar22of32;
                case {'horizontal_decinc_bar_23_of_32', 'horizontal_bar_decinc_23_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar23of32;
                case {'horizontal_decinc_bar_24_of_32', 'horizontal_bar_decinc_24_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar24of32;
                case {'horizontal_decinc_bar_25_of_32', 'horizontal_bar_decinc_25_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar25of32;
                case {'horizontal_decinc_bar_26_of_32', 'horizontal_bar_decinc_26_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar26of32;
                case {'horizontal_decinc_bar_27_of_32', 'horizontal_bar_decinc_27_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar27of32;
                case {'horizontal_decinc_bar_28_of_32', 'horizontal_bar_decinc_28_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar28of32;
                case {'horizontal_decinc_bar_29_of_32', 'horizontal_bar_decinc_29_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar29of32;
                case {'horizontal_decinc_bar_30_of_32', 'horizontal_bar_decinc_30_of_32'}
                    obj = Stimuli.HorizontalDecrementIncrementBar30of32;
                case 'moving_bar_0degrees'
                    obj = Stimuli.MovingBar0;
                case 'moving_bar_90degrees'
                    obj = Stimuli.MovingBar90;
                case 'moving_bar_180degrees'
                    obj = Stimuli.MovingBar180;
                case 'moving_bar_270degrees'
                    obj = Stimuli.MovingBar270;
                case 'moving_bar_w_zero_mean'
                    obj = Stimuli.MovingBarW;
                case 'moving_bar_e_zero_mean'
                    obj = Stimuli.MovingBarE;
                case 'moving_bar_s_zero_mean'
                    obj = Stimuli.MovingBarS;
                case 'moving_bar_n_zero_mean'
                    obj = Stimuli.MovingBarN;
                case 'mbar_8pix_0deg'
                    obj = Stimuli.MovingBar8pix0;
                case 'mbar_8pix_30deg'
                    obj = Stimuli.MovingBar8pix30;
                case 'mbar_8pix_60deg'
                    obj = Stimuli.MovingBar8pix60;
                case 'mbar_8pix_90deg'
                    obj = Stimuli.MovingBar8pix90;
                case 'mbar_8pix_120deg'
                    obj = Stimuli.MovingBar8pix120;
                case 'mbar_8pix_150deg'
                    obj = Stimuli.MovingBar8pix150;
                case 'mbar_8pix_180deg'
                    obj = Stimuli.MovingBar8pix180;
                case 'mbar_8pix_210deg'
                    obj = Stimuli.MovingBar8pix210;
                case 'mbar_8pix_240deg'
                    obj = Stimuli.MovingBar8pix240;
                case 'mbar_8pix_270deg'
                    obj = Stimuli.MovingBar8pix270;
                case 'mbar_8pix_300deg'
                    obj = Stimuli.MovingBar8pix300;
                case 'mbar_8pix_330deg'
                    obj = Stimuli.MovingBar8pix330;
                case 'mbar_15pix_0deg'
                    obj = Stimuli.MovingBar15pix0;
                case 'mbar_15pix_30deg'
                    obj = Stimuli.MovingBar15pix30;
                case 'mbar_15pix_60deg'
                    obj = Stimuli.MovingBar15pix60;
                case 'mbar_15pix_90deg'
                    obj = Stimuli.MovingBar15pix90;
                case 'mbar_15pix_120deg'
                    obj = Stimuli.MovingBar15pix120;
                case 'mbar_15pix_150deg'
                    obj = Stimuli.MovingBar15pix150;
                case 'mbar_15pix_180deg'
                    obj = Stimuli.MovingBar15pix180;
                case 'mbar_15pix_210deg'
                    obj = Stimuli.MovingBar15pix210;
                case 'mbar_15pix_240deg'
                    obj = Stimuli.MovingBar15pix240;
                case 'mbar_15pix_270deg'
                    obj = Stimuli.MovingBar15pix270;
                case 'mbar_15pix_300deg'
                    obj = Stimuli.MovingBar15pix300;
                case 'mbar_15pix_330deg'
                    obj = Stimuli.MovingBar15pix330;
                case 'moving_bars_e_n_w_s_18pix_1v_180t'
                    obj = Stimuli.MovingBarCardinal18pix1v180t;
                case 'moving_bars_ne_nw_sw_se_18pix_1v_180t'
                    obj = Stimuli.MovingBarDiagonal18pix1v180t;
                case 'moving_bars_e_n_w_s_20pix_1v_180t'
                    obj = Stimuli.MovingBarCardinal20pix1v180t;
                case 'moving_bars_e_n_w_s_20pix_3v_180t'
                    obj = Stimuli.MovingBarCardinal20pix3v180t;
                case 'moving_bars_ne_nw_sw_se_20pix_1v_180t'
                    obj = Stimuli.MovingBarDiagonal20pix1v180t;
                case 'moving_bars_full_e_n_w_s_20pix_1v_180t'
                    obj = Stimuli.MovingBarFullCardinal20pix1v180t;
                case 'moving_bars_full_ne_nw_sw_se_20pix_1v_180t'
                    obj = Stimuli.MovingBarFullDiagonal20pix1v180t;
                case 'vertical_moving_bar'
                    obj = Stimuli.VerticalMovingBar;
                case 'melanopsin_22m_180t'
                    obj = Stimuli.Melanopsin_22m_180t;
                case 'melanopsin_27m_180t'
                    obj = Stimuli.Melanopsin_27m_180t;
                case 'l_dec'
                    obj = Stimuli.LConeDecrement;
                case 'l_inc'
                    obj = Stimuli.LConeIncrement;
                case 'm_dec'
                    obj = Stimuli.MConeDecrement;
                case 'm_inc'
                    obj = Stimuli.MConeIncrement;
                case 's_dec'
                    obj = Stimuli.SConeDecrement;
                case 's_inc'
                    obj = Stimuli.SConeIncrement;
                case 'l_m_inc'
                    obj = Stimuli.LMConeIncrement;
                case 'l_m_dec'
                    obj = Stimuli.LMConeDecrement;
                case 'luminance_chirp'
                    obj = Stimuli.LuminanceChirp;
                case 'luminance_squarewave_1hz'
                    obj = Stimuli.LuminanceSquarewave1;
                case 'luminance_background_80t'
                    obj = Stimuli.LuminanceBaseline;
                case 'luminance_increment_20s_80t'
                    obj = Stimuli.LuminanceIncrement20s80t;
                case 'luminance_increment_10s_80t'
                    obj = Stimuli.LuminanceIncrement10s80t;
                case 'luminance_increment_5s_80t'
                    obj = Stimuli.LuminanceIncrement5s80t;
                case 'luminance_increment_3s_80t'
                    obj = Stimuli.LuminanceIncrement3s80t;
                case 'luminance_decrement_20s_80t'
                    obj = Stimuli.LuminanceDecrement20s80t;
                case 'luminance_decrement_10s_80t'
                    obj = Stimuli.LuminanceDecrement10s80t;
                case 'luminance_decrement_5s_80t'
                    obj = Stimuli.LuminanceDecrement5s80t;
                case 'luminance_decrement_3s_80t'
                    obj = Stimuli.LuminanceDecrement3s80t;
                case 'topticasim_background_adapt'
                    obj = Stimuli.TopticaSimBaselineAdapt;
                case 'topticasim_contrast_increment_20s_adapt'
                    obj = Stimuli.TopticaSimIncrement20s;
                case 'lightsoff'
                    obj = Stimuli.LightsOff;
                otherwise
                    obj = Stimuli.Other;
                    warning('Unrecognized stimulus %s', char(str));
            end
        end

        function stim = getNoise(noiseSeed, isBinary)
            if nargin < 2
                isBinary = false;
            end

            T = 1500;
            preTime = 250;
            tailTime = 125;
            frameDwell = 5;

            noiseStd = 0.3;
            bkgd = 0.5;

            noiseStream = RandStream('mt19937ar', 'Seed', noiseSeed);

            stim = bkgd + zeros(1, T);
            for i = 1:preTime+1 : frameDwell : T-tailTime
                stim(i) = noiseStd * bkgd * noiseStream.randn;
            end
            if isBinary
                stim = sign(stim);
            end
            stim = stim + bkgd;
        end

        function stim = getModulation(temporalFrequency, stimFrames, squarewave)
            if nargin < 3
                squarewave = false;
            end

            bkgd = 0.5;
            t = (1:stimFrames) / 25;

            if squarewave
                stim = bkgd * sign(sin(temporalFrequency * 2 * pi * t)) + bkgd;
            else
                stim = bkgd * sin(temporalFrequency * 2 * pi * t) + bkgd;
            end
        end
    end
end