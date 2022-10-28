function writeCData(h, fName)

    h = get(h, 'Children');
    if isa(h, 'matlab.ui.Figure')
        h = findobj(h, 'Type', 'axes');
    end
    if isa(h, 'matlab.graphics.axis.Axes')
        h = get(h, 'Children');
    end
    
    if isa(h, 'matlab.graphics.primitive.Image')
        imwrite(h.CData, fName, 'png');
    end

    
    