classdef P2P < Computer
    
    methods (Access = public)
        
        function obj = P2P()
            obj.name = 'P2P';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = peak2peak(signal);
        end
                
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n + 2;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end