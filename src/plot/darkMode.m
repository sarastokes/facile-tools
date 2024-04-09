function darkMode(status, figHandle)
% DARKMODE
%
% Syntax:
%   darkMode(status)
%   darkMode(status, figHandle)
%
% Optional inputs:
%   status          string, "on" or "off"
%   figHandle       one or more figureHandles (default = gcf)

    arguments
        status      (1,1)   string {mustBeMember(status, ["", "on", "off"])} = ""
        figHandle   = gcf
    end

    if ~isscalar(figHandle)
        arrayfun(@(x) darkMode(status, x), figHandle);
        return
    end

    if status == ""
        if isequal(figHandle.Color, [0 0 0])
            status = "off";
        else
            status = "on";
        end
    end

    axHandles = findall(figHandle, "Type", "axes");
    legendHandles = findall(figHandle, "Type", "legend");

    switch status
        case "on"
            bkgd = [0 0 0];
            txt = [1 1 1];
            lines = [0.85 0.85 0.85];
        case "off"
            lines = [0.15 0.15 0.15];
            bkgd = [1 1 1];
            txt = [0 0 0];
    end

    set(figHandle, "Color", bkgd);
    arrayfun(@(x) set(x, "Color", bkgd, "XColor", txt, "YColor", txt, "GridColor", lines), axHandles);
    arrayfun(@(x) set(x, "Color", bkgd, "TextColor", txt, "EdgeColor", lines), legendHandles);
    arrayfun(@(x) set(x.Title, "Color", txt), axHandles);
