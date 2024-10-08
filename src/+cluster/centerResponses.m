function out = centerResponses(data)

    % Want averaging done previously in pipeline
    if ndims(data) == 3
        out = zeros(size(data));
        for i = 1:size(data, 3)
            out(:,:,i) = cluster.centerResponses(squeeze(data(:,:,i)));
        end
        return
    end

    out = bsxfun(@rdivide, bsxfun(@minus, data, mean(data,2)), std(data,[],2));