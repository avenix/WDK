classdef SignalVectorMagnitude < Computer
    
    methods (Access = public)
        
        function obj = SignalVectorMagnitude()
            obj.name = 'SignalVectorMagnitude';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kNx2);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(sqrt(signal(:,1).^2 + signal(:,2).^2)) / size(signal,1);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 7 * n;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
