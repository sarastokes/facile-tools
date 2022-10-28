function saveCalibrationFile(ledObj, savePath)
    % SAVECALIBRATIONFILE
    %
    % Syntax:
    %   saveCalibrationFile(ledObj, savePath)
    %
    % See also:
    %   CONEISOLATION, SAVEJSON
    % 
    % History:
    %   10Feb2022 - SSP
    % ---------------------------------------------------------------------
        
    if ~endsWith(savePath, '.json')
        error('savePath must end with .json');
    end
    
    S = struct();
    S.FileCreated = datestr(now);
    S.CalibrationDate = ledObj.CALIBRATION;
    S.Files.Spectra = ledObj.DEFAULT_LED_FILES;
    S.Files.LUT = ledObj.DEFAULT_LUT_FILES;
    S.NDF = ledObj.NDF;
    S.LedMaxPowers_uW = ledObj.ledPowers;
    S.LedBackground_Norm = ledObj.ledMeans';
    S.MeanChromaticity_xyY = round(ledObj.meanChromaticity, 3)';

    % Write the powers for each stimulus
    S.Stimuli = struct();
    S.Stimuli.Powers = struct();
    S.Stimuli.Contrasts = struct();
    k = ledObj.stimPowers.keys;

    % Background is always the same, only need it listed once
    T = ledObj.stimPowers(k{1});
    S.Stimuli.Powers.Background = round(T.Bkgd, 5)';

    for i = 1:numel(k)
        T = ledObj.stimPowers(k{i});
        S.Stimuli.Powers.(k{i}) = struct();
        S.Stimuli.Powers.(k{i}) = round(T.dP, 5)';

        S.Stimuli.Contrasts.(k{i}) = round(ledObj.stimContrasts(k{i}),5)';
    end

    S.Stimuli.Powers.Units = 'uW';
    S.Stimuli.Powers.Labels = {'R', 'G', 'B'};
    S.Stimuli.Powers.Description = 'The change in power from the background powers for a 100% contrast increment.';
    S.Stimuli.Contrasts.Units = 'Norm';
    S.Stimuli.Contrasts.Labels = {'L', 'M', 'S', 'Lum'};


    S.LUTs = struct();
    S.Spectra = struct();

    S.LUTs.Files = ledObj.DEFAULT_LUT_FILES;
    T = ledObj.luts;
    S.LUTs.Voltages = T(:,1)';
    S.LUTs.R = T(:,2)';
    S.LUTs.G = T(:,3)';
    S.LUTs.B = T(:,4)';

    S.Spectra.Files = ledObj.DEFAULT_LED_FILES;
    S.Spectra.Wavelengths = ledObj.rawSpectra{1}(:,1)';
    S.Spectra.R = ledObj.rawSpectra{1}(:, 2)';
    S.Spectra.G = ledObj.rawSpectra{2}(:, 2)';
    S.Spectra.B = ledObj.rawSpectra{3}(:, 2)';

    savejson('', S, savePath);
    fprintf('Saved as %s\n', savePath);
end