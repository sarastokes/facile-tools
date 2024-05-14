function REG = batchSiftRegistration(imStack, refID, varargin)

    ip = inputParser();
    ip.CaseSensitive = false;
    ip.KeepUnmatched = true;
    addParameter(ip, 'TransformType', "affine", @istext);
    addParameter(ip, 'OmitSkips', false, @islogical);
    addParameter(ip, 'Plot', false, @islogical);
    addParameter(ip, 'IDs', 1:size(imStack,3), @isnumeric);
    parse(ip, varargin{:});

    omitSkips = ip.Results.OmitSkips;
    IDs = ip.Results.IDs;
    tformType = ip.Results.TransformType;
    plotFlag = ip.Results.Plot;

    assert(numel(IDs) == size(imStack, 3), ...
        'Number of IDs must match number of images');

    % Extract reference from IDs and imStack
    refIdx = find(IDs==refID); disp(refIdx)
    IDs(IDs==refID) = [];
    FIXED = imStack(:,:, refIdx);
    regStack = imStack; regStack(:,:,refIdx) = [];
        
    REG = []; 
    for i = 1:size(regStack, 3)

        MOVING = regStack(:,:,i);
        obj1 = performSIFT(FIXED, MOVING, IDs(i), tformType, plotFlag);
        
        if obj1.Warning
            if tformType == "affine"
                obj2 = performSIFT(FIXED, MOVING, IDs(i), "similarity", plotFlag);
            else
                obj2 = performSIFT(FIXED, MOVING, IDs(i), "affine", plotFlag);
            end
            if obj2.SSIM > obj1.SSIM
                obj = obj2;
                fprintf('SSIM = %.3f -> %.3f\n', obj.OldSSIM, obj.SSIM);
            else
                obj = obj1;
            end
        else
            obj = obj1;
            fprintf('SSIM = %.3f -> %.3f\n', obj.OldSSIM, obj.SSIM);
        end

        REG = cat(1, REG, obj);
    end

    figure();  hold on;
    stem(IDs, REG.getSSIM() - REG.getOldSSIM(), ...
        'Color', 'b', 'Marker', '.', 'MarkerSize', 15);
    zeroBar(gca, 'y');
end

function obj = performSIFT(FIXED, MOVING, ID, tformType, plotFlag)
    
    refPoints = detectSIFTFeatures(FIXED, "Sigma", 1.5);
    [refFeatures, refValidPoints] = extractFeatures(FIXED, refPoints);

    points = detectSIFTFeatures(MOVING, "Sigma", 1.5);
    [features, validPoints] = extractFeatures(MOVING, points);

    indexPairs = matchFeatures(refFeatures, features);
    refMatchedPoints = refValidPoints(indexPairs(:,1),:);
    matchedPoints = validPoints(indexPairs(:,2), :);

    [tform, inlierIdx, status] = estgeotform2d( ...
        matchedPoints, refMatchedPoints,...
        tformType, "MaxDistance", 1.5, "Confidence", 99);

    obj = SiftRegistrationResult(tform, ID, refMatchedPoints, matchedPoints, inlierIdx);
    obj.computeQualityMetrics(FIXED, MOVING);

    if plotFlag
        figure(); 
        showMatchedFeatures(FIXED, MOVING, refMatchedPoints, matchedPoints);

        outputView = imref2d(size(FIXED));
        imReg = imwarp(MOVING, tform, "OutputView", outputView);

        figure(); imshowpair(FIXED, imReg);
        title(num2str(ID));
    end


end