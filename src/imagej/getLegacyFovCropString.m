function txt = getLegacyFovCropString(p)

    switch p.ImagingSide
        case 'left'
            if isequal(p.FieldOfView, [496 400])
                txt = "width=238 height=398 x=1 y=1";
            elseif isequal(p.FieldOfView, [496, 496])
                txt = "width=238 height=494 x=1 y=1";
            else
                txt = "width=248 height=358 x=0 y=1 slice=1";
            end
        case 'right'  % 20220308 on
            if isequal(p.FieldOfView, [496 360])
                txt = "width=242 height=360 x=254 y=0 slice=1";
            elseif isequal(p.FieldOfView, [496 496]) % skipping row at top and bottom
                txt = "width=242 height=494 x=254 y=1 slice=1";
            elseif isequal(p.FieldOfView, [496 408])
                txt = "width=240 height=406 x=255 y=1 slice=1";
            elseif isequal(p.FieldOfView, [496 392])
                txt = "width=242 height=390 x=253 y=1 slice=1";
            elseif isequal(p.FieldOfView, [496 400])
                txt = "width=238 height=398 x=258 y=1";
            end
        case 'right_smallFOV'
            txt = "width=120 height=360 x=376 y=0 slice=1";
        case 'top'
            txt = "width=496 height=168 x=0 y=240 slice=1";
        otherwise
            warning('Imaging side %s not recognized', p.ImagingSide);
    end