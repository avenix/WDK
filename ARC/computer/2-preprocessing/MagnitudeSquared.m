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
            flops = 2 * 3 * size(input,1);
            memory = size(input,1) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
