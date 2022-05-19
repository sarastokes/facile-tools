function h5createwrite(hdfFile, targetPath, data)
    % H5CREATEWRITE
    %
    % Description:
    %   Chains h5create and h5write for use with simple matrices
    %
    % Syntax:
    %   h5createwrite(hdfFile, targetPath, data)
    %
    % History:
    %   16Jan2022 - SSP
    % -------------------------------------------------------------
    
    try
        h5create(hdfFile, targetPath, size(data));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:imagesci:h5create:datasetAlreadyExists')
            warning('Dataset %s already existed, continuing', targetPath);
        else
            rethrow(ME);
        end
    end
            
    h5write(hdfFile, targetPath, data);