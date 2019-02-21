classdef SquaredMagnitudeSum < Computer
    
    methods (Access = public)
        
        function obj = SquaredMagnitudeSum()
            obj.name = 'SquaredMagnitudeSum';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(signal.^2);
        end
                
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n + 1;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end