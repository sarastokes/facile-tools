function rf = twoConeRF(kc, rc, ks, rs, offset, x)
    % TWOCONERF

    rf = kc * (normpdf(x, -offset, rc) + normpdf(x, offset, rc)) / 2;
    rf = rf - (ks * normpdf(x, 0, rs));
    