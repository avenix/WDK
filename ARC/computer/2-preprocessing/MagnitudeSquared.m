classdef MagnitudeSquared < Computer
    
    properties (Access = public)
        inPlaceComputation = false;
    end
    
    methods (Access = public)
        
        function obj = MagnitudeSquared()
            obj.name = 'E';
            obj.inputPort = ComputerDataType.kSignal3;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            dataOut = x(:,1).^2 + x(:,2).^2 + x(:,3).^2;
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 2 * n;
            
            if obj.inPlaceComputation
                memory = 1;
            else
                memory = n;
            end
            
            outputSize = n;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
