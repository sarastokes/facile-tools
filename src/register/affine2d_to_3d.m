function tform3D = affine2d_to_3d(tform2D)

    if isa(tform2D, 'affine2d')
        T = tform2D.T;
    elseif isa(tform2D, 'simtform2d')
        tform3D = simtform3d([tform2D.Scale, tform2D.Scale, 0],...
            [tform2D.Rotation, 0], [tform2D.Translation, 0]);
        return
    elseif isnumeric(tform2D)
        T = tform2D;
    else
        error('affine2d_to_3d:InvalidInputType',...
            'Inputs of class %s are not supported', class(tform2D));
    end

    T2 = eye(4);
    T2(2,1) = T(2,1);
    T2(1,2) = T(1,2);
    T2(4,1) = T(3,1);
    T2(4,2) = T(3,2);

    tform3D = affine3d(T2);