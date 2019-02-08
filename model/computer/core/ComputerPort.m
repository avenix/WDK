classdef ComputerPort < handle
    properties
        type %ComputerPortType
        size %ComputerSizeType
    end
    
    methods(Access = public)
        function obj = ComputerPort(type,size)
            obj.type = type;
            if(nargin > 1)
                obj.size = size;
            else
                obj.size = ComputerSizeType.kOne;
            end
        end
        
        function result = toStruct(obj)
            result = struct("type",obj.type,"size", obj.size);
        end
        
        function b = isSameType(obj,portType)
            b = (portType.type == obj.type && portType.size == obj.size);
        end
    end
end
