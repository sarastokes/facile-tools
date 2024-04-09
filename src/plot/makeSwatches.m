function makeSwatches(rgbValues)

    nSwatches = size(rgbValues, 1);

    figure(); hold on;
    for i = 1:nSwatches
        rectangle("Position", [1.5*(i-1)+0.5, 1, 1, 1], ...
            "FaceColor", rgbValues(i,:), "EdgeColor", "none");
    end
    axis equal
    xlim([0 0.5+(1.5*nSwatches)]); ylim([0.5 2]);
