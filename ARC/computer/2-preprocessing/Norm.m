classdef Norm < Computer
    properties (Access = public)
        inPlaceComputation = false;
    end
    
    methods (Access = public)
        
        function obj = Norm()
            obj.name = 'Norm';
            obj.inputPort = ComputerDataType.kSignal3;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            dataOut = abs(x(:,1)) + abs(x(:,2)) + abs(x(:,3));
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
