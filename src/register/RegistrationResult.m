classdef RegistrationResult < handle & matlab.mixin.Heterogeneous

    properties (SetAccess = private)
        ID                  (1,1)       double  {mustBeInteger} = 0
        Transformation      (1,1)       %images.geotrans.internal.MatrixTransformation
        SpatialRefObj       (1,1)
        SSIM                (1,1)       double
        OldSSIM             (1,1)       double
    end

    properties (Dependent)
        Warning             (1,1)       logical
        TransformType       (1,1)       string
    end

    methods
        function obj = RegistrationResult(tform, ID)
            if isa(tform, 'images.geotrans.internal.GeometricTransformation')
                obj.Transformation = tform;
            elseif isstruct(tform)
                obj.Transformation = tform.Transformation;
                obj.SpatialRefObj = tform.SpatialRefObj;
            end

            if nargin > 1 && ~isempty(ID)
                obj.ID = ID;
            end
        end

        function computeQualityMetrics(obj, imFixed, imMoving)
            obj.OldSSIM = ssim(imFixed, imMoving);
            fixedRefObj = imref2d(size(imFixed));
            movingRefObj = imref2d(size(imMoving));
            imReg = imwarp(imMoving, movingRefObj, obj.Transformation,...
                'OutputView', fixedRefObj, 'SmoothEdges', true);
            obj.SSIM = ssim(imFixed, imReg);
            if isempty(obj.SpatialRefObj)
                obj.setSpatialRefObj(imFixed);
            end
        end
    end

    methods (Sealed)
        function imReg = apply(obj, newImage)
            if isempty(obj.SpatialRefObj)
                spatialRefObj = imref2d(size(newImage, 1:2));
            else
                spatialRefObj = obj.SpatialRefObj;
            end

            imReg = imwarp(newImage, imref2d(size(newImage, 1:2)),...
                obj.Transformation, "OutputView", spatialRefObj,...
                "SmoothEdges", true);
        end
    end

    methods
        function value = get.Warning(obj)
            value = (obj.OldSSIM >= obj.SSIM);
        end

        function value = get.TransformType(obj)
            tformClass = class(obj.Transformation);
            if contains(tformClass, "affine")
                value = "affine";
            elseif contains(tformClass, "similarity")
                value = "similarity";
            else
                value = "unknown";
            end
        end
    end

    methods (Sealed)
        function value = getSubset(obj, IDs)
            regIDs = obj.getIDs();
            if any(~ismember(IDs, regIDs))
                error('RegistrationResult:getSubset:InvalidID', 'Invalid ID');
            end
            [~, idx] = ismember(IDs, regIDs);
            value = obj(idx);
        end

        function tf = hasID(obj, targetID)
            if ~isscalar(targetID)
                tf = arrayfun(@(x) obj.hasID(x), targetID);
                return
            end
            tf = ismember(targetID, obj.getIDs());
        end

        function value = getIDs(obj)
            value = arrayfun(@(x) x.ID, obj);
        end

        function value = getSSIM(obj)
            if ~isscalar(obj)
                value = arrayfun(@(x) x.SSIM, obj);
                return
            end
            value = obj.SSIM;
        end

        function value = getOldSSIM(obj)
            if ~isscalar(obj)
                value = arrayfun(@(x) x.OldSSIM, obj);
                return
            end
            value = obj.OldSSIM;
        end
    end

    methods
        function setID(obj, ID)
            obj.ID = ID;
        end

        function setSpatialRefObj(obj, fixedImage)
            if isa(fixedImage, 'imref2d')
                obj.SpatialRefObj = fixedImage;
            else
                obj.SpatialRefObj = imref2d(size(fixedImage, [1 2]));
            end
        end

        function setSSIMs(obj, newValue, oldValue)
            obj.SSIM = newValue;
            obj.OldSSIM = oldValue;
        end

        function setTransform(obj, tform)
            obj.Transformation = tform;
        end
    end
end