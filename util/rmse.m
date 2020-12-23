function y = rmse(a, b)

    y = sqrt(mean((a(:) - b(:))) .^ 2);