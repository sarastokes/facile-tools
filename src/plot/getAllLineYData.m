function [out, x] = getAllLineYData(axHandle)

    h = findall(axHandle, 'Type', 'line');
    out = {};
    for i = 1:numel(h)
        if ~contains(h(i).Tag, 'ZeroBar')
            out = cat(1, out, h(i).YData);
        end
    end

    try
        out = cell2mat(out);
    catch
        % Do nothing
    end

    if nargout == 2
        x = h(1).XData;
    end