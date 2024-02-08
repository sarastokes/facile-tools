function y = gaussCdfNL(x, mu, sigma)

    y = normcdf(x, mu, sigma);
    y = y - y(x==0);
    y = y ./ max(y);