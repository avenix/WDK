classdef MagnitudeSquared < Computer
    
    methods (Access = public)
        
        function obj = MagnitudeSquared()
            obj.name = 'E';
            obj.inputPort = ComputerDataType.kSignal3;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            dataOut = x(:,1).^2 + x(:,2).^2 + x(:,3).^2;
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
