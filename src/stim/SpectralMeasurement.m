classdef SpectralMeasurement < handle & matlab.mixin.Heterogeneous

    properties (SetAccess = private)
        voltage         % V
        wavelengths     % nm
        spectra         % uW/nm/cm2

        minWL           % nm
        maxWL           % nm
        beamDiameter    % mm
    end

    properties (SetAccess = private)
        resolution      % nm
    end

    properties (Dependent)
        power           % uW
        beamArea        % cm2
    end

    methods
        function obj = SpectralMeasurement(data, voltage, beamDiameter, minWL, maxWL)
            arguments
                data            (:,2)   double
                voltage         (1,1)   double  {mustBeNonnegative}
                beamDiameter    (1,1)   double  {mustBePositive}
                minWL           (1,1)   double  {mustBeScalarOrEmpty} = []
                maxWL           (1,1)   double  {mustBeScalarOrEmpty} = []
            end

            obj.wavelengths = data(:, 1);
            obj.spectra = data(:, 2);
            obj.voltage = voltage;
            obj.beamDiameter = beamDiameter;
            obj.minWL = minWL;
            obj.maxWL = maxWL;
            if isempty(obj.maxWL)
                obj.maxWL = max(obj.wavelengths);
            end
            if isempty(obj.minWL)
                obj.minWL = min(obj.wavelengths);
            end

            obj.getResolution();
        end
    end

    methods
        function out = get.power(obj)
            % Multiply by spectral resolution, then integrate
            out = obj.getCleanIrradiance();
            out = sum(out .* obj.resolution);       % uW
            % Multiply by beam area
            out = out * obj.beamArea;               % uW/cm2
        end

        function out = get.beamArea(obj)
            % Beam area (cm2) from beam diameter (mm)
            beamRadius = obj.beamDiameter / 2;          % cm
            out = pi * (beamRadius/10)^2;      % cm2
        end

        function out = getCleanIrradiance(obj)
            % Finds wavelengths outside the desired range
            if isempty(obj.minWL) && isempty(obj.maxWL)
                out = obj.spectra;
                return
            end

            badWLs = obj.wavelengths < obj.minWL | obj.wavelengths > obj.maxWL;
            % Hack for odd spot from spec
            badWLs(obj.wavelengths>=397.5 & obj.wavelengths <= 400) = 1;

            out = obj.spectra;
            out(badWLs) = 0;
        end
    end

    methods (Access = private)

        function getResolution(obj)
            obj.resolution = zeros(size(obj.wavelengths));

            for j = 1:numel(obj.wavelengths)
                if j == 1
                obj.resolution(j) = obj.wavelengths(j+1) - obj.wavelengths(j);
                elseif j == numel(obj.wavelengths)
                obj.resolution(j) = obj.wavelengths(j) - obj.wavelengths(j-1);
                else
                obj.resolution(j) = (obj.wavelengths(j)-obj.wavelengths(j-1))/2 + (obj.wavelengths(j+1)-obj.wavelengths(j))/2;
                end
            end
        end
    end
end