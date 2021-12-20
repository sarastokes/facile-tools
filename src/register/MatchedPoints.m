classdef MatchedPoints < handle 

    properties (SetAccess = private)
        fixedImage 
        movingImage 
        cpstruct
    
        tform
        tformInv 
    end


    properties (Dependent)
        fixedPoints 
        movingPoints
    end

    methods
        function obj = MatchedPoints(movingImage, fixedImage, cpstruct, varargin)

            obj.fixedImage = obj.checkImage(fixedImage);
            obj.movingImage = obj.checkImage(movingImage);
            obj.cpstruct = cpstruct;

            obj.initialize();
        end

        function movingPoints = get.movingPoints(obj)
            [movingPoints, ~] = cpstruct2pairs(obj.cpstruct);
        end

        function fixedPoints = get.fixedPoints(obj)
            [~, fixedPoints] = cpstruct2pairs(obj.cpstruct);
        end
    end

    methods
        function imNew = imwarp(obj, im)
            if nargin ~= 2
                im = obj.movingImage;
            end 
            imNew = imwarp(im, obj.tform,...
                'OutputView', imref2d(size(obj.fixedImage)));
        end

        function imNew = imwarpInv(obj, im)
            if nargin ~= 2 
                im = obj.fixedImage;
            end
            imNew = imwarp(im, obj.tformInv,...
                'OutputView', imref2d(size(obj.movingImage)));
        end
        
        function newPoints = transformPointsForward(obj, pts)
            newPoints = transformPointsForward(obj.tform, pts);
        end

        function newPoints = transformPointsInverse(obj, pts)
            newPoints = transformPointsInverse(obj.tform, pts);
        end
    end

    methods
        function cpselect(obj)
            cpselect(obj.movingImage, obj.fixedImage, obj.cpstruct);
        end
    end

    methods 

        function app = showReg(obj)
            app = ImageComparisonApp(obj.imwarp(), obj.fixedImage);
        end

        function checkReg(obj)
            figure(); hold on;
            scatter(obj.fixedPoints(:,1), obj.fixedPoints(:,2), 'xr');
            newPts = transformPointsForward(obj.tform, obj.movingPoints);
            scatter(newPts(:,1), newPts(:,2), 'ob');
            legend('Fixed Points', 'Estimated');
            title(sprintf('Avg Error is %.3f', mean(fastEuclid2d(obj.fixedPoints, newPts))));
            axis equal;
            figPos(gcf, 0.8, 0.8);
        end

        function checkRegInv(obj)
            figure(); hold on;
            scatter(obj.movingPoints(:,1), obj.movingPoints(:,2), 'xr');
            newPts = transformPointsInverse(obj.tform, obj.fixedPoints);
            scatter(newPts(:,1), newPts(:,2), 'ob');
            legend('Moving Points', 'Estimated');
            title(sprintf('Avg Error is %.3f', mean(fastEuclid2d(obj.movingPoints, newPts))));
            axis equal;
            figPos(gcf, 0.8, 0.8);
        end
    end

    methods (Access = private)
        function initialize(obj)
            obj.tform = fitgeotrans(obj.movingPoints, obj.fixedPoints, 'projective');
            obj.tformInv = fitgeotrans(obj.fixedPoints, obj.movingPoints, 'projective');
        end
    end
    
    methods (Static)
        
        function im = checkImage(im)
            if ~ismatrix(im)
                im  = rgb2gray(im);
            end
            if isinteger(im)
                im = im2double(im);
            end
        end
    end
end