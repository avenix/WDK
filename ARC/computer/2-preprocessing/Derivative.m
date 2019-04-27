classdef Derivative < Computer
    
    properties (Access = public)    
        order = 1;
        delta = 1;
    end
    
    methods (Access = public)
        function obj = Derivative(order, cutoff)
            if nargin > 0
                obj.order = order;
                obj.cutoff = cutoff;
            end
            obj.name = 'derivative';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function derivative = compute(obj, data)
            if size(data,1) == 1
                derivative = data;
            else
                if obj.order == 1
                    derivative = obj.computeFirstDerivative(data);
                elseif obj.order == 2
                    derivative = obj.computeSecondOrderDerivative(data);
                else
                    derivative = [];
                end
            end
        end
        
        function derivative = computeFirstOrderDerivative(data)
            n = length(data);
            derivative = zeros(1,n);
            for i = 2 : numInputDimensions
                derivative(n) = (data(i) - data(i-1)) / obj.delta;
            end
        end
        
        function derivative = computeSecondOrderDerivative(data)
            n = length(data);
            derivative = zeros(1,n);
            
            derivative(1) = (data(2) - data(1)) / obj.delta;
            derivative(n) = (data(n) - data(n-1)) / obj.delta;
            
            deltaSquared = obj.delta * obj.delta;
            for i = 2 : n-1
                derivative(n) = (data(i-1) - data(i) + data(i+1)) / deltaSquared;
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.order,obj.cutoff);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order,1,2);
            property2 = Property('delta',obj.cutoff,1,200);
            editableProperties = [property1,property2];
        end
        
        function metrics = computeMetrics(obj,input)
            flops = 6 * obj.order * size(input,1);
            memory = size(input,1) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
