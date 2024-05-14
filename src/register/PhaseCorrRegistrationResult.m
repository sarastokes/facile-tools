classdef PhaseCorrRegistrationResult < RegistrationResult

    methods
        function obj = PhaseCorrRegistrationResult(tform, ID)
            obj = obj@RegistrationResult(tform, ID);
        end
    end
end