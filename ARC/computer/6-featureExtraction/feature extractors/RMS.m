classdef RMS < Computer
    
    methods (Access = public)
        
        function obj = RMS()
            obj.name = 'RMS';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = rms(signal);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 8 * n;
            memory = 3 * 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
