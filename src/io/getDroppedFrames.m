function droppedFrames = getDroppedFrames(baseDir, videoID, baseStr)
    % GETDROPPEDFRAMES
    %
    % Syntax:
    %   droppedFrames = getDroppedFrames(baseDir, videoID, baseStr)
    %
    % History:
    %   29Jun2021 - SSP - Irregular table size supports
    % ---------------------------------------------------------------------

    if nargin == 3
        refDir = [baseDir, '\Ref\'];

        f = ls(refDir);
        f = deblank(string(f));

        fileStr = [baseStr, '_ref_'];

        str = [fileStr, int2fixedwidthstr(videoID, 4), '_'];
        idx = find(startsWith(f, str, 'IgnoreCase', true) & endsWith(f, '.csv'));
        if numel(idx) > 1
            warning('%u - found %u registration files', videoID, numel(idx));
            idx = idx(1);
        end
        if isempty(idx)
            warning('%u - registration file not found', videoID);
            droppedFrames = [];
            return
        end

        registrationReportFile = [refDir, char(f(idx))];
    elseif nargin == 2
        registrationReportFile = [baseDir, '\Ref\', char(videoID)];
    end
    
    
    T = readtable(char(registrationReportFile),...
        'ReadVariableNames', false, 'TextType', 'string');
    if size(T, 2) <= 5
        T(T.Var1 == "failed", :) = [];
        droppedFrames = find(T.Var3 == "frame") - 1;
        disp(droppedFrames);
        droppedFrames = droppedFrames - 1;
        disp(droppedFrames);
        % fprintf('\tEpoch %u dropped %u frames\n', videoID, numel(droppedFrames));
    elseif size(T, 2) == 36
        droppedFrames = find(T.Var34 == "frame registration failed");
        if ~isnumeric(T.Var36(1)) && T.Var36(1) == "reg description"
            droppedFrames = droppedFrames - 1;
        end
    elseif size(T, 2) == 22
        droppedFrames = find(T.Var20 == "frame registration failed");
        if T.Var20(1) == "reg description"
            droppedFrames = droppedFrames - 1;
        end
    else
        error([num2str(videoID), ' - check motion correction table size!']);
    end

    



