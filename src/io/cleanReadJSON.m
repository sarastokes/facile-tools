function txt = cleanReadJSON(fName)

    fid = fopen(fName, 'r');

    if fid == -1
        warning('File %s could not be opened', filePath);
        txt = [];
        return
    end

    tmpFile = fullfile(fileparts(which('startup.m')), 'tmp.json');
    if exist(tmpFile, 'file')
        delete(tmpFile);
    end
    tmp = fopen(tmpFile, 'w');

    counter = 0;
    tline = fgetl(fid);
    while ischar(tline)
        if startsWith(strtrim(tline), '\\')
            continue
        end
        if contains(tline, '\\')
            txt = extractBefore(tline, '\\');
        else
            txt = tline;
        end
        fprintf(tmp, txt);
    end
    fclose(fid);

    S = loadjson(tmpFile);
