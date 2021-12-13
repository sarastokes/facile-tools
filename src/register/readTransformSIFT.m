function [x, y] = readTransformSIFT(fileName)
    % READTRANSFORMSIFT
    %
    % Syntax:
    %   [x, y] = readTransformSIFT(fileName)
    %
    % Input:
    %   fileName    char
    %       Filename and path to transformation .txt file
    %
    % Output:
    %   x           1D vector
    %       Translations along x-axis
    %   y           1D vector
    %       Translations along y-axis 
    % 
    % History:
    %   05Jan2020 - SSP
    % ---------------------------------------------------------------------

    % Lines containing transformation matrix values begin with:
    header = 'Transformation Matrix: AffineTransform[[1.0, 0.0, ';

    x = []; y = [];

    fid = fopen(fileName, 'r');
    tline = fgetl(fid);
    while ischar(tline)
        if startsWith(tline, header)
            str = tline(numel(header) + 1 : end);
            str = erase(str, '], [0.0, 1.0,');
            str = erase(str, ']]');
            str = strsplit(str, ' ');
            x = cat(1, x, str2double(str{1}));
            y = cat(1, y, str2double(str{2}));
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    % Make values relative to a first reference image
    if ~isempty(x)
        x = [0; cumsum(x)];
        y = [0; cumsum(y)];
    end

    if nargout == 1
        x = [x, y];
    end