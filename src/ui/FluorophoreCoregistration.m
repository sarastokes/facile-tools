classdef FluorophoreCoregistration < handle 

    properties (SetAccess = private)
        mergedFundus
        rhodamineFundus
        gcampFundus
        
        gcampAO
        rhodamineAO
    end

    properties 
        gAO_to_gcamp
        rAO_to_rhodamine
        rhodamine_to_merged
        gcamp_to_merged 
    end

    methods 
        function obj = FluorophoreCoregistration()


        end

        function cpselect(obj, whichTransform)

            [movingPoints, fixedPoints] = cpstruct2pairs(cpstruct);
        end

        function save(obj, whichTransform)
            x = obj.(whichTransform);

            save('');
        end
    end

    methods (Access = private)
        function x = getTransform(obj, whichTransform)
            x = obj.(whichTransform);
        end
    end
end 