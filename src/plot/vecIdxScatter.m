function vecIdxScatter(vec1, vec2, idx, varargin)
    % VECIDXSCATTER
    %
    % Syntax:
    %   vecIdxScatter(vec1, vec2, idx, varargin)
    %
    % History:
    %   02Nov2022 - SSP
    % ---------------------------------------------------------------------

    if nargin < 4
        opts = 'ob';
    else
        opts = varargin;
    end

    if islogical(idx)
        pts = find(idx);
    else
        pts = idx;
    end
    for i = 1:numel(pts)    
        h = plot(vec1(pts(i)), vec2(pts(i)), opts{:});
        h.Tag =  num2str(pts(i));
    end

    