classdef Data < handle
    properties (Access = public)
        type
    end
    
    methods
        function obj = Data(type)
            if nargin == 1
                obj.type = type;
            end
        end
    end
end