function acts = plotLayerActivations(net, layerName, img)

    arguments
        net
        layerName   (1,1)  string
        img
    end

    acts = activations(net, img(1:64, 1:64), layerName);
    acts = reshape(acts, [64 64 1 64]);

    figure();
    imshow(imtile(acts, 'GridSize', [8 8]));
    title(layerName + " Activations");