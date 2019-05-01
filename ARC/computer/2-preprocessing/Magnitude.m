classdef Magnitude < Computer
    
    properties (Access = public)
        inPlaceComputation = false;
    end
    
    methods (Access = public)
        
        function obj = Magnitude()
            obj.name = 'Magnitude';
            obj.inputPort = ComputerDataType.kSignal3;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            dataOut = sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            
            flops = 4 * n;
            
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
