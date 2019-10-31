classdef ConstantMultiplier < Computer
    
    properties (Access = public)
        constant = 1;
    end
    
    methods (Access = public)
        
        function obj = ConstantMultiplier(constant)
            if nargin > 0
                obj.constant = constant;
            end
            obj.name = 'ConstantMultiplier';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kSignal;
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = signal .* obj.constant;
        end
        
        function str = toString(obj)
            str = sprintf('%s%d',obj.name,obj.constant);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('constant',obj.constant);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n;
            memory = n;
            outputSize = n;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
