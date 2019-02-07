classdef Change < Computer
    
    properties (Access = public)
        property; % a string representing the property to access
    end
    
    methods (Access = public)
        function obj = Change(property)
            if nargin > 0
                obj.property = property;
            end
            
            obj.name = 'change';
            obj.inputPort = ComputerPort(ComputerPortType.kAny);
            obj.outputPort = ComputerPort(ComputerPortType.kAny);
        end
        
        function computedSignal = compute(obj,data)
            computedSignal = data.(obj.property);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name,obj.property);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('property',obj.property);
        end
    end
end