classdef TemporalModulation < handle

    properties
        stimTime(1,1)           {mustBePositive}                      = 1
        ledMeans(1,3)           double

        preTime(1,1)            {mustBeNonnegative}
        tailTime(1,1)           {mustBeNonnegative}
        contrast(1,1)           {mustBeInRange(contrast, -1, 1)}
        baseIntensity(1,1)      {mustBeInRange(baseIntensity, 0, 1)}
        temporalFrequency(1,1)  {mustBePositive}                      = 5
        sinewave(1,1)           logical
    end

    properties (Dependent)
        amplitude
        ledRange
        totalTime
        temporalClass
    end

    properties (Hidden, Constant)
        LED_RESOLUTION = 2;     % ms
        SAMPLE_RATE = 500;      % Hz
    end
    
    methods
        function obj = TemporalModulation(stimTime, ledMeans, varargin)
            obj.stimTime = stimTime;
            obj.ledMeans = ledMeans;
            
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'PreTime', 0, @isnumeric);
            addParameter(ip, 'TailTime', 0, @isnumeric);
            addParameter(ip, 'TemporalFrequency', 5, @isnumeric);
            addParameter(ip, 'Contrast', 1, @isnumeric);
            addParameter(ip, 'BaseIntensity', 0.5, @isnumeric);
            addParameter(ip, 'Sinewave', true, @islogical);
            parse(ip, varargin{:});

            obj.preTime = ip.Results.PreTime;
            obj.tailTime = ip.Results.TailTime;
            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.baseIntensity = ip.Results.BaseIntensity;
            obj.contrast = ip.Results.Contrast;
            obj.sinewave = ip.Results.Sinewave;
        end

        function value = get.amplitude(obj)
            value = obj.contrast * obj.baseIntensity;
        end

        function value = get.ledRange(obj)
            value = 2 * obj.ledMeans;
        end

        function value = get.totalTime(obj)
            value = obj.preTime + obj.stimTime + obj.tailTime;
        end

        function value = get.temporalClass(obj)
            if obj.sinewave
                value = 'sine';
            else
                value = 'square';
            end
        end

        function value = sec2led(obj, x)
            % SEC2LED
            %
            % Syntax:
            %   value = sec2led(obj, x)
            % -------------------------------------------------------------
            value = x * (1000/obj.LED_RESOLUTION);
        end
        
        function value = led2sec(obj, x)
            % LED2SEC
            %
            % Syntax:
            %   value = led2sec(obj, x)
            % -------------------------------------------------------------
            value = x / (1000 / obj.LED_RESOLUTION);
        end

        function stim = generate(obj)
            % GENERATE
            %
            % Syntax:
            %   stim = generate(obj)
            % -------------------------------------------------------------
            dt = 1 / obj.SAMPLE_RATE;
            t = 0:dt:obj.stimTime-dt;
            stim = sin(2*pi*obj.temporalFrequency*t);
            stim = obj.amplitude * stim;


            if obj.preTime > 0
                prePts = obj.sec2led(obj.preTime);
                stim = [zeros(1, prePts), stim];
            end

            if obj.tailTime > 0
                tailPts = obj.sec2led(obj.tailTime);
                stim = [stim, zeros(1, tailPts)];
            end
            stim = stim + obj.baseIntensity;
        end

        function ledValues = mapToLeds(obj)
            % MAPTOLEDS
            %
            % Syntax:
            %   ledValues = mapToLeds(obj)
            % -------------------------------------------------------------
            data = obj.generate();
            ledValues = data .* obj.ledRange';
        end

        function ledPlot(obj)
            % LEDPLOT
            %
            % Syntax:
            %   ledPlot(obj)
            % -------------------------------------------------------------
            ledValues = obj.mapToLeds();
            ledPlot(ledValues, obj.led2sec(1:size(ledValues, 2)));
            title(obj.getFileName(), 'Interpreter','none');
            figPos(gcf, 1.5, 1);
            tightfig(gcf);
        end

        function writeStim(obj)
            % WRITESTIM
            % 
            % Syntax:
            %   writeStim(obj)
            % -------------------------------------------------------------
            ledValues = obj.mapToLeds();
            makeLEDStimulusFile(obj.getFileName(), ledValues);
        end

        function fName = getFileName(obj)
            % GETFILENAME
            % 
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = sprintf('luminance_%s_%uhz_%up_%ut_%s.txt',...
                obj.temporalClass, obj.temporalFrequency,...
                100*obj.baseIntensity, obj.totalTime,...
                datetime(datestr(now), 'Format', 'ddMMMuuuu'));
        end
    end
end