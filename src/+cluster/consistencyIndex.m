function CI = consistencyIndex(data, clusterIDs)

    N = max(clusterIDs);
    CI = zeros(1, N);
    for i = 1:N
        y = data(clusterIDs == i, :);
        a = std(mean(y, 1), [], 2);
        b = mean(std(y, [], 2), 1);
        CI(i) = a / b;
    end