function [pts, vector] = directedVector(A, B, mag)

    if nargin < 3
        mag = 1;
    end

    if size(B, 1) > 1 && size(A, 1) == 1
        A = repmat(A, [size(B, 1), 1]);
    end

    % Get the unit vector
    vector = B - A;
    vector = vector(:, 1:2);
    for i = 1:size(vector, 1)
        vector(i,:) = vector(i,:) ./ norm(vector(i,:));
    end

    % Now scale and translate
    pts = [zeros(size(vector)), vector];
    pts = mag * pts;
    pts = pts + [B, B];

