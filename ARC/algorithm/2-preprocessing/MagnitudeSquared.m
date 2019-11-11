classdef MagnitudeSquared < Algorithm
    
    methods (Access = public)
        
        function obj = MagnitudeSquared()
            obj.name = 'E';
            obj.inputPort = DataType.kSignal3;
            obj.outputPort = DataType.kSignal;
        end
        
        function dataOut = compute(~,x)
            if size(x,2) < 3
                fprintf('%s\n',Constants.kInvalidInputMagnitude);
            else
                dataOut = x(:,1).^2 + x(:,2).^2 + x(:,3).^2;
            end
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
