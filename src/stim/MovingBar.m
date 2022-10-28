classdef MovingBar < handle

    properties
        stimTime(1,1) double
        barSize(1,1) {mustBeInteger}
        speed(1,1) {mustBeInteger}
        direction(1,1) {mustBeInRange(direction, 0, 360)}
        useAperture(1,1) logical
    end

    properties (Hidden, Constant)
        SAMPLE_RATE = 25;
        CANVAS_SIZE = [256 256];
    end

    methods
        function obj = MovingBar(stimTime, varargin)
            obj.stimTime = stimTime;

            ip = inputParser();
            addParameter(ip, 'BarSize', 20, @isnumeric);
            addParameter(ip, 'Speed', 1, @isnumeric);
            addParameter(ip, 'Direction', 0, @isnumeric);
            addParameter(ip, 'UseAperture', true, @islogical);
            parse(ip, varargin{:});

            obj.barSize = ip.Results.BarSize;
            obj.speed = ip.Results.Speed;
            obj.direction = ip.Results.Direction;
            obj.useAperture = ip.Results.UseAperture;
        end
    end

    methods
        function exportVideo(obj)
            import stage.core.*;

            monitor = stage.core.Monitor(1);
            window = stage.core.Window(obj.CANVAS_SIZE, false, monitor,... 
                'RefreshRate', obj.SAMPLE_RATE);
            canvas = stage.core.Canvas(window, 'DisableDwm', false);

            bar = stage.builtin.stimuli.Rectangle();
            bar.size = [obj.barSize, 2*max(obj.CANVAS_SIZE)];
            bar.orientation = obj.direction;

            if obj.useAperture
                mask = stage.builtin.stimuli.Rectangle();
                mask.color = 0;
                mask.position = obj.CANVAS_SIZE / 2;
                mask.orientation = obj.direction;
                mask.size = 2 * obj.CANVAS_SIZE(1) * ones(1,2);
                sc = obj.CANVAS_SIZE(1) / (2*obj.CANVAS_SIZE(1));
                mask.setMask(stage.core.Mask.createCircularAperture(sc));
            end

            barPositionController = stage.builtin.controllers.PropertyController(...
                bar, 'position', @(state)obj.getBarPosition(state.time*obj.SAMPLE_RATE));

            presentation = stage.core.Presentation(obj.stimTime);
            presentation.addStimulus(bar);
            if obj.useAperture
                presentation.addStimulus(mask);
            end
            presentation.addController(barPositionController);

            player = stage.builtin.players.RealtimePlayer(presentation);
            player.exportMovie(canvas, obj.getFileName(), obj.SAMPLE_RATE);
            
            presentation.play(canvas);
        end

        function p = getBarPosition(obj, time)
            inc = time * obj.speed - (obj.CANVAS_SIZE(1)/2) - obj.barSize/2;
            p = [cos(deg2rad(obj.direction)) sin(deg2rad(obj.direction))];
            p = p .* (inc*ones(1,2)) + obj.CANVAS_SIZE/2;
        end

        function fName = getFileName(obj)
            apertureFlag = '_';
            if ~obj.useAperture
                apertureFlag = '_full_';
            end
            fName = sprintf('moving_bar%s%udeg_%upix_%uv_%ut.txt',...
                apertureFlag, obj.direction, obj.barSize, obj.speed, obj.stimTime);
        end
    end

end