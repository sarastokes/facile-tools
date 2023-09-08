function dreams = plotDeepDream(net, layer, numRC, resizeFac)

    if nargin < 3
        numRC = 5;
    end
    if nargin < 4
        resizeFac = 1;
    end
    numChannels = numRC^2;

    dreams = deepDreamImage(net, layer, 1:numChannels);
    size(dreams)

    figure();
    imshow(imresize(imtile(dreams, 'GridSize', [numRC, numRC]), resizeFac));
    title(layer);
