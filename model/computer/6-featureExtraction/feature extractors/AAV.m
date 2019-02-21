classdef AAV < Computer
    
    methods (Access = public)
        
        function obj = AAV()
            obj.name = 'AAV';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = single(0);
            
            for i = 1 : length(signal)-1
                result = result + single(abs(signal(i+1) - signal(i)));
            end
            result = result / length(signal);
        end
        
        function metrics = computeMetrics(~,input)
            flops = 5 * size(input,1) + 2;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end