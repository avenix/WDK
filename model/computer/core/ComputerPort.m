classdef ComputerPort < handle
    properties
        type ComputerPortType
        size
    end
    
    methods(Access = public)
        function obj = ComputerPort(type,size)
            obj.type = type;
            obj.size = size;
        end
        
        function b = isSameType(obj,portType)
            b = (portType.type == obj.type && strcmp(portType.size, obj.size));
        end
    end
end
