function T = readJsonLED(fileName)
    J = loadjson(fileName);
    dataTable = J.datatable;
    lines = strsplit(dataTable, newline);


    frameNumber = []; ID = []; voltage1 = []; voltage2 = []; voltage3 = [];
    timestamp = []; 

    for i = 2:numel(lines)
        if isempty(lines{i})
            continue
        end
        entries = strsplit(lines{i}, ', ');
        frameNumber = cat(1, frameNumber, str2double(entries{1}));
        ID = cat(1, ID, str2double(entries{2}));
        voltage1 = cat(1, voltage1, str2double(entries{4}));
        voltage2 = cat(1, voltage2, str2double(entries{5}));
        voltage3 = cat(1, voltage3, str2double(entries{6}));
        timestamp = cat(1, timestamp, str2double(entries{7}));
    end

    T = table(frameNumber, ID, voltage1, voltage2, voltage3, timestamp,...
        'VariableNames', {'Frame', 'ID', 'R', 'G', 'B', 'TimeStamp'});
    T{end, 'Frame'} = T{end-1, 'Frame'};
