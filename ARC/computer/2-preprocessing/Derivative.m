classdef Derivative < Computer
    
    properties (Access = public)    
        order = 1;
        delta = 1;
        inPlaceComputation = true;
    end
    
    methods (Access = public)
        function obj = Derivative(order, delta)
            if nargin > 0
                obj.order = order;
                if nargin > 1
                    obj.delta = delta;
                end
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
                    derivative = obj.computeFirstOrderDerivative(data);
                elseif obj.order == 2
                    derivative = obj.computeSecondOrderDerivative(data);
                else
                    derivative = [];
                end
            end
        end
        
        function derivative = computeFirstOrderDerivative(obj,data)
            n = length(data);
            derivative = zeros(n,1);
            for i = 2 : n
                derivative(i) = (data(i) - data(i-1)) / obj.delta;
            end
        end
        
        function derivative = computeSecondOrderDerivative(obj,data)
            n = length(data);
            derivative = zeros(n,1);
            
            derivative(1) = (data(2) - data(1)) / obj.delta;
            derivative(n) = (data(n) - data(n-1)) / obj.delta;
            
            deltaSquared = obj.delta * obj.delta;
            for i = 2 : n-1
                derivative(i) = (data(i-1) - data(i) + data(i+1)) / deltaSquared;
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%.2f',obj.name,obj.order,obj.delta);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order,1,2);
            property2 = Property('delta',obj.delta);
            editableProperties = [property1,property2];
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 6 * obj.order * size(input,1);
            if obj.inPlaceComputation
                memory = 1;
            else
                memory = n * Constants.kSensorDataBytes;
            end
            outputSize = n * Constants.kSensorDataBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
