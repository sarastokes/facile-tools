function dsetID = h5writeCharDataset(fileName, pathName, txt)

    fileID = H5F.open(fileName);
        
    typeID = H5T.copy('H5T_C_S1');
    H5T.set_size(typeID, 'H5T_VARIABLE');
    H5T.set_strpad(typeID,'H5T_STR_NULLTERM');
    dspaceID = H5S.create('H5S_SCALAR');
    dsetID = H5D.create(pathName, 'ID', typeID, dspaceID, 'H5P_DEFAULT');
    H5T.close(typeID);
    H5S.close(dspaceID);
    H5D.write(dsetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', txt);
    if nargout == 0
        H5D.close(dsetID);
    end
    H5F.close(fileID);