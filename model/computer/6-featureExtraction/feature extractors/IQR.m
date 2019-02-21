classdef IQR < Computer
    
    methods (Access = public)
        
        function obj = IQR()
            obj.name = 'IQR';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = iqr(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n * log2(n) + n;
            memory = n * 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end