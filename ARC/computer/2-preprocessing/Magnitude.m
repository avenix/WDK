classdef Magnitude < Computer
    
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
            flops = 4 * size(input,1);
            memory = size(input,1) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
