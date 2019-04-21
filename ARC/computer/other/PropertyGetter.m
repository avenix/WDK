classdef PropertyGetter < Computer
    
    properties (Access = public)
        property; % a string representing the property to access
    end
    
    methods (Access = public)
        function obj = PropertyGetter(property)
            if nargin > 0
                obj.property = property;
            end
            
            obj.name = 'getter';
            obj.inputPort = ComputerDataType.kAny;
            obj.outputPort = ComputerDataType.kAny;
        end
        
        function computedSignal = compute(obj,data)
            computedSignal = data.(obj.property);
        end
        
        function metrics = computeMetrics(obj,input)
            flops = 1;
            computedSignal = input.(obj.property);
            memory = Helper.ComputeObjectSize(computedSignal);
            outputSize = memory;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name,obj.property);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('property',obj.property);
        end
    end
end
