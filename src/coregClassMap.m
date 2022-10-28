function rgcPlot = coregClassMap(regObj, T, keyword, plotFlag)

    if nargin < 4
        plotFlag = true;
    end

    searchFun = @(x, t) contains(x, t) & ~contains(x, join([t, "?"], ""));
    refObj = imref2d([size(regObj.roiMaps,1), size(regObj.roiMaps,2)]);

    rgcs = find(searchFun(T.Class, keyword));
    rgcPlot = zeros(refObj.ImageSize);

    
    for i = 1:numel(rgcs)
        addedToPlot = false;
        dsetID = 0;
        while ~addedToPlot
            dsetID = dsetID + 1;
            iRoi = T{rgcs(i), dsetID+3};
            if iRoi > 0
                iMap = double(squeeze(regObj.roiMaps(:,:,dsetID)) == iRoi);
                if dsetID ~= 1
                    iMap = imwarp(iMap, regObj.tforms(dsetID-1),...
                        'OutputView', refObj); %, 'Interp', 'nearest');
                    iMap(iMap > 0) = i;
                    rgcPlot = rgcPlot + iMap;
                else
                    iMap(iMap > 0) = i;
                    rgcPlot = rgcPlot + iMap;
                end
                addedToPlot = true;
                fprintf('%s found in %s\n', T.UID(rgcs(i)), T.Properties.VariableNames{dsetID+3});
            else
                addedToPlot = false;
            end
        end
    end
        
    if plotFlag
        figure();
        imagesc(rgcPlot);
        axis equal tight off
    end

