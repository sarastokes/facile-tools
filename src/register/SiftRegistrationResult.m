classdef SiftRegistrationResult < RegistrationResult

    properties
        matchedPoints       SIFTPoints
        refPoints           SIFTPoints
        inlierIdx
    end

    methods
        function obj = SiftRegistrationResult(tform, ID, refPoints, matchedPoints, inlierIdx)
            obj@RegistrationResult(tform, ID);


            obj.refPoints = refPoints;
            obj.matchedPoints = matchedPoints;
            obj.inlierIdx = inlierIdx;
        end
    end
end