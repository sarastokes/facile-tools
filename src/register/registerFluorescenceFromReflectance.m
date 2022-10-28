function registerFluorescenceFromReflectance(experimentDir, epochID)
    % REGISTERFLUORESCENCEFROMREFLECTANCE
    %
    % History:
    %   09Mar2022 - SSP
    % ---------------------------------------------------------------------

    % Get registration reports
    x = ao.builtin.RegistrationReportReader(experimentDir, epochID);
    T = x.read();

    y = ao.builtin.UnregisteredVideoReader(experimentDir, 'vis', epochID);
    imStack = y.read();
    imStackReg = zeros(size(imStack));
    for i = 1:size(imStack,3)
        imStackReg(:,:,i) = imtranslate(flipud(imStack(:,:,i)),...
             [T.frame_y(i) -T.frame_x(i)], 'FillValues', 0);
    end

    regFileName = strrep(x.fileName, '_ref_', '_vis_');
    regFileName = strrep(regFileName, '.csv', '.avi');
    regFileName = strrep(regFileName, 'motion', 'frame');

    stack2video([y.filePath, filesep, regFileName], imStackReg);
    fprintf('Wrote to: %s\n', [y.filePath, filesep, regFileName]);



