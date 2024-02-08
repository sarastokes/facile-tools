classdef Color
    % COLOR Represents a color
    %
    %     Has a red, green, blue, and alpha components. Can be instantiated
    %     from an rgb(a) vector or a hex string.

    properties
        % R The red component of the color
        r = 0;

        % G The green component of the color
        g = 0;

        % B The blue component of the color
        b = 0;

        % A The alpha level of the color
        a = 255;
    end

    methods
        function obj = Color(varargin)
            % Construct a color class from various different types of data.
            % Accepts a variable number of arguments
            %
            % Zero arguments:
            %     Defaults to black ([0 0 0 255])
            %
            % One argument:
            %     string: A hex string, with or without a leading hash
            %         Ex: '#FFA425', 'fF8bC2', '#81FD9155'
            %     vector: An RGB(A) vector
            %         Ex: [255 150 150 100]
            %
            % Three arguments:
            %     r, g, b, respectively
            %
            % Four arguments:
            %     r, g, b, a, respectively

            if nargin == 0
                obj.r = 0;
                obj.g = 0;
                obj.b = 0;
                obj.a = 255;
            elseif nargin == 1
                arg = varargin{1};

                if ischar(arg)
                    if arg(1) == '#' && (length(arg) == 7 || length(arg) == 9)
                        arg = arg(2:length(arg));
                    elseif length(arg) ~= 6 && length(arg) ~= 8
                        error('Malformed hex string: %s', arg);
                    end
                    obj.r = hex2dec(arg(1:2));
                    obj.g = hex2dec(arg(3:4));
                    obj.b = hex2dec(arg(5:6));
                    if length(arg) == 8
                        obj.a = hex2dec(arg(7:8));
                    else
                        obj.a = 255;
                    end
                elseif isfloat(arg)
                    if length(arg) ~= 3 && length(arg) ~= 4
                        error('RGB float matrix must be of length 3 or 4');
                    elseif any(arg > 255) || any(arg < 0)
                        error('RGB float matrix must contains values between 0 and 255, inclusive');
                    end

                    obj.r = arg(1);
                    obj.g = arg(2);
                    obj.b = arg(3);

                    if length(arg) == 4
                        obj.a = arg(4);
                    else
                        obj.a = 255;
                    end
                else

                end
            elseif nargin == 3
                r = varargin{1};
                g = varargin{2};
                b = varargin{3};

                if any([r g b] > 255) || any([r g b] < 0)
                    error('RGB floats must be between 0 and 255, inclusive');
                end

                obj.r = r;
                obj.g = g;
                obj.b = b;
                obj.a = 255;
            elseif nargin == 4
                r = varargin{1};
                g = varargin{2};
                b = varargin{3};
                a = varargin{4};

                if any([r g b a] > 255) || any([r g b a] < 0)
                    error('RGBA floats must be between 0 and 255, inclusive');
                end

                obj.r = r;
                obj.g = g;
                obj.b = b;
                obj.a = a;
            end
        end

        function ret = rgb(obj)
            % Returns the RGB vector, normalized to [0, 1]

            ret = [obj.r obj.b obj.g] / 255;
        end

        function ret = rgba(obj)
            % Returns the RGBA vector, normalized to [0, 1]

            ret = [obj.r obj.b obj.g obj.a] / 255;
        end

        function ret = cmyk(obj, alpha)
            % Returns the CMYK vector for this color, normalized to [0, 1]
            %
            % Parameters:
            %     alpha - If true, alpha will be the fifth element in the
            %             returned vector

            rp = obj.r / 255;
            gp = obj.g / 255;
            bp = obj.b / 255;

            k = 1 - max([rp gp bp]);
            c = (1 - rp - k) / (1 - k);
            m = (1 - gp - k) / (1 - k);
            y = (1 - bp - k) / (1 - k);

            ret = [c m y k];

            if nargin == 2 && alpha
                ret(5) = obj.a / 255;
            end
        end

        function ret = hsv(obj)
            % Returns the HSV color vector for this color.
            rc = obj.r / 255;
            gc = obj.g / 255;
            bc = obj.b / 255;

            mx = max([rc gc bc]);
            mn = min([rc gc bc]);

            if rc == gc && gc == bc
                h = 0;
            else
                if mx == rc
                    h = 60 * (gc - bc) / (mx - mn);
                elseif mx == gc
                    h = 60 * (2 + ((bc - rc) / (mx - mn)));
                else
                    h = 60 * (4 + ((rc - gc) / (mx - mn)));
                end
            end

            if h < 0
                h = h + 360;
            end

            if mx == 0
                s = 0;
            else
                s = (mx - mn) / mx;
            end

            v = mx;

            ret = [h s v];
        end

        function ret = hsva(obj)
            % Returns the HSLA color vector for this color.
            ret = [obj.hsv() obj.a / 255];
        end

        function ret = hsl(obj)
            % Returns the HSL color vector for this color.
            rc = obj.r / 255;
            gc = obj.g / 255;
            bc = obj.b / 255;

            mx = max([rc gc bc]);
            mn = min([rc gc bc]);

            if rc == gc && gc == bc
                h = 0;
            else
                if mx == rc
                    h = 60 * (gc - bc) / (mx - mn);
                elseif mx == gc
                    h = 60 * (2 + ((bc - rc) / (mx - mn)));
                else
                    h = 60 * (4 + ((rc - gc) / (mx - mn)));
                end
            end

            if h < 0
                h = h + 360;
            end

            if mx == 0 || mn == 1
                s = 0;
            else
                s = (mx - mn) / (1 - abs(mx - mn - 1));
            end

            l = (mx + mn) / 2;

            ret = [h s l];
        end

        function ret = hsla(obj)
            % Returns the HSLA color vector for this color.
            ret = [obj.hsl() obj.a / 255];
        end
    end
end
