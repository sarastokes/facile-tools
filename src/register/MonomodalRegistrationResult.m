classdef MonomodalRegistrationResult < RegistrationResult

    properties
        Blur        (1,1)     logical 
        Normalize   (1,1)     logical
        Alignment   (1,1)     string    {mustBeMember(Alignment, ["center of mass", "geometric"])} = "geometric"
    end

    methods
        function obj = MonomodalRegistrationResult(tform, ID, varargin)
        
            obj = obj@RegistrationResult(tform, ID);

            ip = inputParser();
            addParameter(ip, 'Blur', false, @islogical);
            addParameter(ip, 'Normalize', false, @islogical);
            addParameter(ip, 'Alignment', "geometric", @istext);
            parse(ip, varargin{:});

            obj.Blur = ip.Results.Blur;
            obj.Normalize = ip.Results.Normalize;
            obj.Alignment = ip.Results.Alignment;
        end
    end
end