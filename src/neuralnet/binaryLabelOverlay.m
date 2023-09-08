function binaryLabelOverlay(dsTable, idx)

    if nargin < 2
        idx = 1;
    end
    image = dsTable.InputImage(idx);
    image = image{1};

    label = dsTable.ResponsePixelLabelImage(idx);
    label = label{1};
    label = uint8(label);
    disp(class(label))

    B = labeloverlay(image, label,...
        'Transparency', 0.8, 'Colormap', [0 1 1; 1 1 0]);
    imshow(B);
    tightfig(gcf);