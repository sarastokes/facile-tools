function stim = applySystemNonlinearity(stim0, visualize, powerClip)
    % APPLYSYSTEMNONLINEARITY
    % 
    % Syntax:
    %   stim = applySystemNonlinearity(stim)
    %
    % Inputs:
    %   stim 0      [1 x T]
    %       Stimulus coded between 0 and 1
    % Optional inputs:
    %   visualize   logical (default = false)
    %       Plot the conversion steps
    %   powerClip   logical (default = false)
    %       Clip powers before flatline
    % 
    % Outputs:
    %   stim        [1 x T]
    %       Stimulus coded between 0 and 255
    %
    % History:
    %   20201209 - SSP - converted from Tyler's script
    %   20210104 - SSP - added alternative to point-by-point calculation
    %   20210616 - SSP - option to clip powers before flat line
    % ---------------------------------------------------------------------

    if nargin < 2
        visualize = false;
    end
    if nargin < 3
        powerClip = false;
    end

    dataDir = [fileparts(fileparts(mfilename('fullpath'))), filesep, 'data'];
    load([dataDir, filesep, 'toptica_nonlinearity_2pctPWR.mat'])

    if powerClip
        lowerBound = max(powers == min(powers));
        upperBound = min(powers == max(powers));
        powers = powers(lowerBound:upperBound);
        grayscale = grayscale(lowerBound:upperBound);
    end
    
    lookup_fit = fit(grayscale, powers, 'cubicinterp');
    lookup_table = lookup_fit(0:255);

    % Apply laser nonlinearity
    powerRange = max(powers) - min(powers);
    powerStim = powerRange * stim0 + min(powers);

    % Convert to 0-255
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

    if visualize
        figure();
        subplot(311); hold on;
        plot(stim0, 'LineWidth', 1.25); 
        title('Normalized Input');
        ylim([0 1]);

        subplot(312); hold on;
        plot(powerStim, 'LineWidth', 1.25); 
        title('Toptica Output (uW)');
        ylim([min(powers), max(powers)]);

        subplot(313); hold on;
        plot(stim, 'LineWidth', 1.25); 
        title('Video Output (uint8)');
        ylim([0, 255]);
        figPos(gcf, 0.7, 1);
    end