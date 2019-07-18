classdef Norm < Computer
    
    methods (Access = public)
        
        function obj = Norm()
            obj.name = 'Norm';
            obj.inputPort = ComputerDataType.kSignal3;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            dataOut = abs(x(:,1)) + abs(x(:,2)) + abs(x(:,3));
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = n * Constants.kSensorDataBytes;
            outputSize = n * Constants.kSensorDataBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
