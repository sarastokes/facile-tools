classdef SpectralMeasurement < handle & matlab.mixin.Heterogeneous

    properties (SetAccess = private)
        voltage         % V
        wavelengths     % nm
        spectra0        % uW/nm/cm2

        minWL           % nm
        maxWL           % nm
        beamDiameter    % mm

        NDF     
        backgroundSpectra
    end

    properties (SetAccess = private)
        resolution      % nm
    end

    properties (Dependent)
        power           % uW
        beamArea        % cm2
        spectra         % uW/nm/cm2
        peakWavelength  % nm
    end

    methods
        function obj = SpectralMeasurement(data, voltage, beamDiameter, minWL, maxWL, NDF)
            arguments
                data            (:,2)   double
                voltage         (1,1)   double  {mustBeNonnegative}
                beamDiameter    (1,1)   double  {mustBePositive}
                minWL           (1,1)   double  {mustBeScalarOrEmpty} = []
                maxWL           (1,1)   double  {mustBeScalarOrEmpty} = []
                NDF             = []
            end

            obj.wavelengths = data(:, 1);
            obj.spectra0 = data(:, 2);
            obj.voltage = voltage;
            obj.beamDiameter = beamDiameter;
            obj.minWL = minWL;
            obj.maxWL = maxWL;
            obj.setNDF(NDF);

            if isempty(obj.maxWL)
                obj.maxWL = max(obj.wavelengths);
            end
            if isempty(obj.minWL)
                obj.minWL = min(obj.wavelengths);
            end

            obj.getResolution();
        end

        function setNDF(obj, ndf)
            if isempty(ndf) 
                obj.NDF = [];
                return
            end
            ndf = convertCharsToStrings(ndf);

            for i = 1:numel(ndf)
                if ~endsWith(ndf, ".txt")
                    ndf = ndf + ".txt";
                end
                tf = calibration.validateNDF(ndf);
                if ~tf
                    continue
                end
            end
            if tf
                obj.NDF = ndf;
            end
        end

        function setBackground(obj, backgroundSpectra)
            obj.backgroundSpectra = backgroundSpectra;
        end
    end

    % Dependent set/get methods
    methods
        function out = get.power(obj)
            % Multiply by spectral resolution, then integrate
            %out = obj.getCleanIrradiance();
            out = obj.spectra;

            out = sum(out .* obj.resolution);       % uW
            % Multiply by beam area
            out = out * obj.beamArea;               % uW/cm2
        end

        function out = get.spectra(obj)
            % Spectra with NDF
            out = obj.getCleanIrradiance();
            if ~isempty(obj.NDF)
                for i = 1:numel(obj.NDF)
                    out = dichroicSpectra(obj.NDF(i), [obj.wavelengths, out], "transmit", false);
                end
            end
        end

        function out = get.peakWavelength(obj)
            [~, idx] = max(obj.spectra);
            out = obj.wavelengths(idx);
        end

        function out = get.beamArea(obj)
            % Beam area (cm2) from beam diameter (mm)
            beamRadius = obj.beamDiameter / 2;          % cm
            out = pi * (beamRadius/10)^2;      % cm2
        end
    end

    methods
        function out = getCleanIrradiance(obj)
            % Returns spectra with background subtracted and cutoff applied
            % but no NDF attenuation.

            out = obj.spectra0;

            % Subtract the background (noise) spectra
            if ~isempty(obj.backgroundSpectra)
                out = out - obj.backgroundSpectra;
            end

            % Finds wavelengths outside the desired range
            if isempty(obj.minWL) && isempty(obj.maxWL)
                return
            end

            badWLs = obj.wavelengths < obj.minWL | obj.wavelengths > obj.maxWL;
            % Hack for odd spot from spec
            badWLs(obj.wavelengths>=397.5 & obj.wavelengths <= 400) = 1;

            % Remove wavelengths below and above cutoffs
            out(badWLs) = 0;

            % Set negative numbers to zero
            out(out < 0) = 0;
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