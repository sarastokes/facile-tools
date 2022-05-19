function T = appendRoiUID(dataset)
    T = dataset.roiUIDs;

    x = dataset.roiUIDs.UID;
    noUIDs = find(x == "");
    
    alphabet = 'abcdefghijklmnopqrstuvwxyz';
   
    a = 1;
    tmp = startsWith(x, alphabet(a));
    while nnz(tmp) > 0
        a = a + 1;
        tmp = startsWith(x, alphabet(a));
    end
    a = a - 1;

    b = 1;
    tmp = startsWith(x, alphabet([a, b]));
    while nnz(tmp) > 0
        b = b + 1;
        if b == 27
            b = 1;
            a = a + 1;
        end
        tmp = startsWith(x, alphabet([a, b]));
    end
    b = b - 1;
    
    c = 1;
    tmp = startsWith(x, alphabet([a, b, c]));
    while nnz(tmp) > 0
        c = c + 1;
        if c == 27
            c = 1;
            b = b + 1;
        end
        tmp = startsWith(x, alphabet([a, b, c]));
    end

    for i = 1:numel(noUIDs)
        idx = noUIDs(i);
        if c == 27
            b = b + 1;
            c = 1;
        end
        T{T.ID == idx, 'UID'} = string(alphabet([a, b, c]));
        c = c + 1;

    end
