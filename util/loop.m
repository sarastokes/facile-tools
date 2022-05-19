function data = loop(data)

    if size(data, 1) == 1
        data = [data, data(1)];
    elseif size(data, 2) == 1
        data = [data; data(1)];
    end
end