classdef NHP < double

    enumeration
        MW00618 (618)
        MW00702 (702)
        MW00838 (838)
        MW00848 (848)
        MW00846 (846)
        MW00851 (851)
        MW02105 (2105)
        MW02121 (2121)
    end

    methods 
        function id = fullID(obj)
            % FULLID
            % 
            % Syntax:
            %   id = fullID(obj)
            % -------------------------------------------------------------
            id = ['201', num2str(double(obj))];
            id = [id(1:4), '-', id(end-1:end)];
        end

        function out = axialLength(obj, whichEye)
            % AXIALLENGTH
            %
            % Syntax:
            %   out = axialLength(obj, whichEye)
            %
            % Input:
            %   whichEye        char
            %       Either 'OD' or 'OS'
            % Output: 
            %   axial length in mm
            % -------------------------------------------------------------

            whichEye = upper(whichEye);
            assert(ismember(whichEye, {'OD', 'OS'}));

            import ao.NHP
            switch obj 
                case NHP.MW00618
                    if strcmp(whichEye, 'OD')
                        out = 18.8;
                    else
                        out = 18.99;
                    end
                case NHP.MW00702
                    if strcmp(whichEye, 'OS')
                        out = 17.2;
                    else
                        out = NaN;
                    end
                case NHP.MW00838
                    if strcmp(whichEye, 'OD')
                        out = 16.56;
                    end
                case NHP.MW00846
                    if strcmp(whichEye, 'OD')
                        out = 16.04;
                    else
                        out = 16.19;
                    end
                case NHP.MW00848
                    if strcmp(whichEye, 'OD')
                        out = 18.47;
                    else
                        out = 18.59;
                    end
                case NHP.MW00851
                    if strcmp(whichEye, 'OD')
                        out = 16.88;
                    else
                        out = 16.97;
                    end
                case NHP.MW02105
                    if strcmp(whichEye, 'OD')
                        out = 21.18;
                    else
                        out = 21.21;
                    end
            end            
        end

        function out = sex(obj)
            import ao.NHP;
            switch obj 
                case NHP.MW00838
                    out = 'F';
                case NHP.MW00848
                    out = 'M';
                case NHP.MW00851
                    out = 'F';
                case NHP.MW02105
                    out = 'M';
                otherwise
                    out = 'Unknown';
            end
        end

        function out = micronsPerDegree(obj, eyeName)
            out = 291.2 * (obj.axialLength(eyeName) / 24.2);
        end

        function otf = getOTF(obj, wl, sf)
            % GETOTF
            %   otf = getOTF(obj, wl, sf)
            % -------------------------------------------------------------

            u0 = (obj.pupilSize() * pi * 10e5) / (wl * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end

        function um = deg2um(obj, deg, eyeName)
            um = obj.micronsPerDegree(eyeName) * deg;
        end

        function deg = um2deg(obj, um, eyeName)
            deg = um ./ obj.micronsPerDegree(eyeName);
        end

        function umPerPixel = micronsPerPixel(obj, eyeName, fovDegrees)
            % MICRONSPERPIXEL
            % 
            % Input:
            %   fovDegrees      numeric [1 x 2]
            %       Field of view in degrees
            % -------------------------------------------------------------
            
            umPerPixel = obj.deg2um(fovDegrees, eyeName) / 256;
        end

        function value = degreesPerPixel(obj, eyeName, fovDegrees)
            % DEGREESPERPIXEL
            % -------------------------------------------------------------

            umPerPixel = obj.micronsPerPixel(eyeName, fovDegrees);
            value = obj.um2deg(umPerPixel, eyeName);
        end
    end

    % Hard-coded values for Tyler's analyses
    methods
        function out = peakSF(obj)
            switch obj
                case NHP.MW00702
                    out = 4;
                case NHP.MW00838
                    out = 10;
            end
        end

        function out = dfMin(obj)
            switch obj 
                case NHP.MW00702
                    out = -0.2;
                case NHP.MW00838
                    out = -0.55;
            end
        end
    end

    methods (Static)
        function d = pupilSize()
            % PUPILSIZE  
            d = 6.7;    % diameter, mm
        end

        function obj = init(ID)
            import ao.NHP
            if ischar(ID)
                if contains(ID, '702')
                    obj = NHP.MW00702;
                elseif contains(ID, '838')
                    obj = NHP.MW00838;
                elseif contains(ID, '848')
                    obj = NHP.MW00848;
                elseif contains(ID, '105')
                    obj = NHP.MW02105;
                elseif contains(ID, '2121')
                    obj = NHP.MW02121;
                else
                    error('Unrecognized ID string: %s', ID);
                end
            elseif isnumeric(ID)
                switch ID
                    case 702
                        obj = NHP.MW00702;
                    case 838
                        obj = NHP.MW00838;
                    case 848
                        obj = NHP.MW00848;
                    case 851
                        obj = NHP.MW00851;
                    case 2105
                        obj = NHP.MW02105;
                    case 2121
                        obj = NHP.MW02121;
                    otherwise
                        error('Unrecognized ID number: %u', ID);
                end
            else
                error('Unrecognized ID format, must be numeric or char');
            end
        end
    end
end 