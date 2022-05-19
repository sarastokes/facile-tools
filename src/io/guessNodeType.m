function nodeType = guessNodeType(data)

    if isstring(data) || ischar(data)
        if exist(data, 'file')
            nodeType = ao.ui.ExternalFileNode;
        else
            nodeType = ao.ui.TextNode;
        end
    elseif istable(data)
        % nodeType = ao.ui.TableNode;
    elseif isa(data, 'uint8') && ndims(data) == 2  %#ok
        nodeType = ao.ui.ImageNode;
    elseif islogical(data) && ndims(data) == 2  %#ok
        % nodeType = ao.ui.MaskNode;
    end
