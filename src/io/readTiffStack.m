function ts = readTiffStack(fileName)
    % READTIFFSTACK
    %
    % Description:
    %   A slightly slower alternative to TIFFStack
    %
    % Syntax:
    %   ts = readTiffStack(fileName)
    %
    % Notes:
    %   Assumes 8 bit image
    %
    % See also:
    %   TIFFSTACK
    % ---------------------------------------------------------------------

    assert(endsWith(fileName, '.tif'), 'Input must be a tif file!');
    if ~exist(fileName, "file")
        error('File not found! %s', fileName);
    end

    imInfo = imfinfo(fileName);
    nFrames = size(imfinfo(fileName));
    
    ts = zeros(imInfo(1).Height, imInfo(1).Width, 'uint8');

    for i = 1:nFrames
        ts(:,:,i) = imread(fileName, 'Index', i);
    end