classdef GammaRampMeasurement < handle
% GAMMARAMPMEASUREMENT
%
% Description:
%   Quantifies a light source's input-output function as measured by an
%   Ocean Optics spectrometer. Assumes one of the measurements is at 0 to
%   provide a noise floor.
%
% Constructor:
%   obj = GammaRampMeasurement("420nm", "C:\420nm", 5:-0.1:0, 2, "20220422")
%
% Inputs:
%   lightSource             string
%       Light source's name (e.g., "420 nm" or "Blue")
%   filePath                string, must be a folder
%       The folder where the measurements are located
%   values                  vector
%       The light source's inputs for each measurement (e.g., voltage to an
%       LED or 8-bit value to a projector). These must match the order in
%       which the measurements were collected.
%   beamDiameter            double
%       Diameter of beam on sensor in mm
%   calibrationDate         string
%       Date calibration was performed (I use YYYYmmDD but don't enforce
%       conversion to datetime since we mainly use it for file naming)
% Optional key/value inputs:
%   Token                   string
%       A token used to identify the desired measurement .txt files. Use to
%       omit unrelated .txt files (default = "_AbsoluteIrradiance_")
%   ND                      double
%       Value of neutral density filter(s) in place when measurement was
%       made (default is 0)
%   MinWL                   double  (default = N/A)
%       Minimum wavelength expected for spectra (values for wavelengths
%       below this will be set to zero to minimize impact of noise)
%   MaxWL                   double  (default = N/A)
%       Maximum wavelength expected for spectra (values for wavelengths
%       above this will be set to zero to minimize impact of noise)
%
% Use:
%   obj = GammaRampMeasurement("420nm", "C:\420nm", 5:-0.1:0, 2,...
%       "20220422", "Token", "420nm_Abs", "MinWL", 400, "MaxWL", 450);
%   % Plot the normalized spectra, then write to file
%   obj.plotSpectra(); obj.writeSpectra("C:\Spectra\");
%   % See the input-output lookup table (optionally upsample values)
%   obj.plotLUT(0:0.05:5);
%   % Save the lookup table
%   obj.writeLUT("C:\LUTs", )
%
% History:
%   7Apr2024 - SSP - Adapted from Tyler's script
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        lightSource                 (1,1)       string
        values                      (1,:)       {mustBeNumeric}
        Measurements
        calibrationDate
        beamDiameter                (1,1)       double       % mm
        neutralDensityFilter        (1,1)       double = 0
        importProps                 (1,1)       struct
    end

    properties (Dependent)
        numMeasurements             (1,1)       {mustBeInteger}
        intensities                             double
        spectra                                 double
        wavelengths                             double
        powers                                  double
    end

    methods
        function obj = GammaRampMeasurement(lightSource, filePath, ...
                values, beamDiameter, calibrationDate, opts)
            arguments
                lightSource     (1,1)   string
                filePath        (1,1)   string      {mustBeFolder}
                values          (1,:)   double
                beamDiameter    (1,1)   double      {mustBePositive}
                calibrationDate (1,1)   string
                opts.Token      (1,1)   string      = "_AbsoluteIrradiance_"
                opts.ND         (1,1)   double      {mustBeNonnegative} = 0
                opts.MinWL      (1,1)   double      {mustBeScalarOrEmpty} = []
                opts.MaxWL      (1,1)   double      {mustBeScalarOrEmpty} = []
            end

            obj.lightSource = lightSource;
            obj.values = values;
            obj.neutralDensityFilter = opts.ND;
            obj.beamDiameter = beamDiameter;
            obj.calibrationDate = calibrationDate;

            obj.importProps = struct(...
                'Folder', filePath, 'Token', opts.Token,...
                'MinWL', opts.MinWL, 'MaxWL', opts.MaxWL);

            obj.importMeasurements();
        end

        function refresh(obj)
            obj.importMeasurements();
        end
    end

    % Dependent set/get methods
    methods
        function out = get.numMeasurements(obj)
            out = numel(obj.Measurements);
        end

        function out = get.intensities(obj)
            out = arrayfun(@(x) x.voltage, obj.Measurements);
            out = round(out, 10);
        end

        function out = get.wavelengths(obj)
            out = obj.Measurements(end).wavelengths;
        end

        function out = get.powers(obj)
            out = arrayfun(@(x) x.power, obj.Measurements);
            if obj.Measurements(1).voltage == 0
                out(1) = 0;
            end
        end

        function out = get.spectra(obj)
            if isempty(obj.Measurements)
                out = [];
                return
            end

            out = obj.getNormalizedSpectra();
        end
    end

    % Core methods
    methods
        function out = getNormalizedSpectra(obj, targetValue)
            if nargin < 2
                targetValue = max(obj.intensities);
            end

            idx = find(obj.intensities == targetValue);

            noiseSpectra = obj.Measurements(1).getCleanIrradiance();
            out = obj.Measurements(idx).getCleanIrradiance() - noiseSpectra;
            out = out / max(out);
        end

        function T = getLUT(obj, targetValues)
            if nargin < 2
                targetValues = 0:0.01:5;
            end

            if any(~ismember(targetValues, obj.intensities))
                pwr = obj.interpolate(targetValues);
            else
                pwr = obj.powers;
            end

            T = table(obj.intensities, pwr,...
                "VariableNames", {"Input", "Power"});
        end
    end

    % File output methods
    methods
        function writeLUT(obj, savePath, varargin)
            arguments
                obj
                savePath        (1,1)   string  {mustBeFolder}
            end
            arguments (Repeating)
                varargin
            end

            fName = sprintf('%s_%s_LUT_%sndf.txt',...
                obj.lightSource, obj.calibrationDate, obj.neutralDensityFilter);
            fName = fullfile(savePath, fName);

            T = obj.getLUT(varargin{:});
            % Variable names wanted by Qiang's AOSLO code...
            T.Properties.VariableNames = {'VOLTAGE', 'POWER'};

            writetable(T, fName);
            fprintf('Saved LUT as %s\n', fName);
        end

        function writeSpectra(obj, savePath, targetValue, fName)
            arguments
                obj
                savePath        (1,1)   string  {mustBeFolder}
                targetValue     (1,1)   double  = max(obj.intensities)
                fName           (1,1)   string  = ""
            end

            data = obj.getNormalizedSpectra(targetValue);
            if fName == ""
                fName = sprintf('%s_%s_%sndf_%s.txt',...
                    obj.lightSource, obj.calibrationDate, obj.neutralDensityFilter);
            end

            fName = fullfile(savePath, fName);
            T = table(obj.wavelengths, data,...
                "VariableNames", {"Lambda", "Normalized"});
            writetable(T, fName);
            fprintf('Saved normalized spectra as %s\n', fName);
        end
    end

    % Plotting methods
    methods
        function plotSpectra(obj, opts)
            arguments
                obj
                opts.Parent                         = []
                opts.Area       (1,1)   logical     = true
                opts.Color                          = [0.5 0.5 1]
            end

            if isempty(opts.Parent)
                axHandle = axes('Parent', figure('Name', 'NormSpectra'));
                hold on;
                xlim([380, 720]); xlabel('Wavelength (nm)');
                ylim([0 1]); ylabel('Normalized');
                title(obj.lightSource);
                grid on;
            else
                axHandle = opts.Parent;
            end

            if opts.Area
                area(obj.wavelengths, obj.spectra,...
                    "FaceColor", opts.Color, "EdgeColor", [0.1 0.1 0.1],...
                    "LineWidth", 1, "FaceAlpha", 0.5, "Parent", axHandle);
            else
                plot(axHandle, obj.wavelengths, obj.spectra,...
                    'Color', opts.Color, 'LineWidth', 1);
            end
        end

        function plotLUT(obj, targetValues)
            arguments
                obj
                targetValues        (1,:)   double = obj.intensities
            end

            if any(~ismember(targetValues, obj.intensities))
                pwr = obj.interpolate(targetValues);
            else
                pwr = obj.powers;
            end
            figure('Name', sprintf('%s LUT', obj.lightSource));
            ax = gca;
            hold(ax, 'on');
            plot(targetValues, pwr, '-ob', 'MarkerFaceColor', [0.5 0.5 1]);
            xlabel('Voltage (V)'); ylabel('Power (uW)');
        end

        function compareNormalizedSpectra(obj, plotValues)
            obj.plotSpectra('Area', false);

            allValues = obj.intensities;

            for i = 1:numel(plotValues)
                if plotValues(i) == max(obj.intensities)
                    continue
                end
                idx = find(allValues == plotValues(i));
                if isempty(idx)
                    error('Value %s not found', num2str(plotValues(i)));
                end
                plot(obj.Measurements(idx).wavelengths, obj.getNormalizedSpectra(plotValues(i)));
            end
        end
    end

    methods (Access = private)
        function importMeasurements(obj)
            [data, fileNames] = loadSpectralMeasurementFiles(...
                obj.importProps.Folder, obj.importProps.Token);

            obj.Measurements = [];
            for i = 1:numel(fileNames)
                newMeasurement = SpectralMeasurement(data{i}, obj.values(i),...
                    obj.beamDiameter, obj.importProps.MinWL, obj.importProps.MaxWL);
                obj.Measurements = [obj.Measurements, newMeasurement];
            end
            obj.Measurements = obj.Measurements';

            [~, idx] = sort(obj.values);
            obj.Measurements = obj.Measurements(idx);
        end

        function out = interpolate(obj, targetValues)
            if any(targetValues < min(obj.intensities)) || any(targetValues > max(obj.intensities))
                error('Values out of range');
            end

            out = interp1(obj.intensities, obj.powers, targetValues);
        end
    end
end