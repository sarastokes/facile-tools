function h5writeTable(hdfName, pathName, data)
    % H5WRITETABLE
    %
    % Description:
    %   Adds table to HDF5 file as a Compound
    %
    % Syntax:
    %   h5writeTable(hdfName, pathName, data);
    %
    % Notes:
    %   Appreciative to NWB for showing the way on this one:
    %   https://github.com/NeurodataWithoutBorders/matnwb/+io/writeCompound.m
    % ---------------------------------------------------------------------

    fileID = ao.io.HDF5.openFile(hdfName);
    nRows = height(data);
    data = table2struct(data);

    names = fieldnames(data);

    S = struct();
    for i = 1:length(names) 
        S.(names{i}) = {data.(names{i})};
    end
    data = S;

    typeIDs = cell(length(names), 1);
    sizes = zeros(size(typeIDs));

    for i = 1:length(names)
        val = data.(names{i});
        if iscell(val) && ~isstring(val)
            data.(names{i}) = [val{:}];
            val = val{1};
        end
        typeIDs{i} = ao.io.HDF5.getDataType(val);
        sizes(i) = H5T.get_size(typeIDs{i});
    end

    typeID = H5T.create('H5T_COMPOUND', sum(sizes));
    for i = 1:length(names)
        % Insert columns into compound type
        H5T.insert(typeID, names{i}, sum(sizes(1:i-1)), typeIDs{i});
    end
    % Optimizes for type size
    H5T.pack(typeID);

    spaceID = H5S.create_simple(1, nRows, []);
    if ao.io.HDF5.exists(hdfName, pathName)
        warning('found and replaced %s', pathName);
        ao.io.HDF5.deleteObject(hdfName, pathName);
    end
    dsetID = H5D.create(fileID, pathName, typeID, spaceID, 'H5P_DEFAULT');
    H5D.write(dsetID, typeID, spaceID, spaceID, 'H5P_DEFAULT', data);
    H5D.close(dsetID);
    H5S.close(spaceID);
    H5F.close(fileID);



