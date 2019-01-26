classdef Property < handle
    properties (Access = public)
        name;
        value = 0;
    end
    
    methods (Access = public)
        function obj = Property(name,value)
            obj.name = name;
            if nargin>1
                obj.value = value;
            end
        end
    end
end