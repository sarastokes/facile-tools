function stim = applySystemNonlinearity3d(stim0)
    % APPLYSYSTEMNONLINEARITY
    % 
    % Syntax:
    %   stim = applySystemNonlinearity(stim)
    %
    % Inputs:
    %   stim 0      [1 x T]
    %       Stimulus coded between 0 and 1
    % 
    % Outputs:
    %   stim        [1 x T]
    %       Stimulus coded between 0 and 255
    %
    % History:
    %   20201209 - SSP - converted from Tyler's script
    %   20210104 - SSP - added alternative to point-by-point calculation
    %   20210616 - SSP - option to clip powers before flat line
    %   20220601 - SSP - removed unused options
    % ---------------------------------------------------------------------

    dataDir = [fileparts(fileparts(fileparts(mfilename('fullpath')))), filesep, 'data'];
    load([dataDir, filesep, 'toptica_nonlinearity_2pctPWR.mat'])
    lookup_fit = fit(grayscale, powers, 'cubicinterp');
    lookup_table = lookup_fit(0:255);

    % Apply laser nonlinearity
    powerRange = max(powers) - min(powers);
    powerStim = powerRange * stim0 + min(powers);

    [x, y, t] = size(powerStim);
    powerStim = powerStim(:);
    stim = zeros(size(powerStim));

    % If there's just a few unique values, don't run point by point
    values = unique(powerStim);
    if numel(values) < 10
        for i = 1:numel(values)
            stim(powerStim == values(i)) = findclosest(lookup_table, values(i));
        end
    else
        for i = 1:numel(powerStim)
            stim(i) = findclosest(lookup_table, powerStim(i));
        end
    end

    stim = uint8(stim - 1);
    stim = reshape(stim, [x y t]);