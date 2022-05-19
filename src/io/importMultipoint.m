function data = importMultipoint(fname)
    % IMPORTMULTIPOINT
    %
    % Description: 
    %   Import data from ImageJ multipoint tool
    %
    % Syntax:
    %   data = importMultipoint(fname)
    %
    % History:
    %   05Sep2021 - SSP
    % ---------------------------------------------------------------------

    fid = fopen(fname);

    tline = fgetl(fid);
    tline = fgetl(fid);

    npts = str2double(tline);
    data = zeros(npts, 2);
    for i = 1:npts
        tline = fgetl(fid);
        txt = strsplit(tline, ' ');
        data(i, 1) = str2double(txt{1});
        data(i, 2) = str2double(txt{2});
    end
    
    fclose(fid);