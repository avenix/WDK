classdef ComputerPort < handle
    properties (Access = public)
        type;
    end
    
    methods(Access = public)
        function obj = ComputerPort(type)
            obj.type = type;
        end
        
        function result = toStruct(obj)
            result = struct("type",obj.type);
        end
        
        function b = isSameType(obj,portType)
            b = (portType.type == obj.type);
        end
    end
end
