function [tforms, TT] = readRigidTransform(fName)
    % READRIGIDTRANSFORM
    %
    % Description:
    %   Get rigid transformations from ImageJ log output
    % 
    % Syntax:
    %   tforms = readRigidTransform(fName)
    %
    % History:
    %   28Oct2021 - SSP
    % ---------------------------------------------------------------------

    assert(isfile(fName), 'Input is not a valid file!');
    header = 'Transformation Matrix: AffineTransform[[';

    TT = [];

    fid = fopen(fName, 'r');
    tline = fgetl(fid);
    while ischar(tline)
        if startsWith(tline, header)
            str = tline(numel(header) + 1 : end);
            str = erase(str, ']');
            str = erase(str, '[');
            str = erase(str, ',');
            t = strsplit(str, ' ');

            T = cellfun(@str2double, t);
            T = reshape(T, [3 2]);
            TT = cat(3, TT, [T, [0 0 1]']);
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    % Account for serial transforms
    tforms = TT;
    tforms(1, 2, :) = cumsum(tforms(1, 2, :));
    tforms(2, 1, :) = cumsum(tforms(2, 1, :));
    tforms(3, 1, :) = cumsum(tforms(3, 1, :));
    tforms(3, 2, :) = cumsum(tforms(3, 2, :));