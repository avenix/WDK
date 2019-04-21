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
            flops = 2 * size(input,1);
            memory = size(input,1) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
