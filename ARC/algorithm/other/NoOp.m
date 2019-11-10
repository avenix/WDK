classdef NoOp < Algorithm

    methods (Access = public)
        
        function obj = NoOp()
            obj.name = 'none';
            obj.inputPort = DataType.kAny;
            obj.outputPort = DataType.kAny;
        end
        
        function out = compute(~, dataIn)
            out = dataIn;
        end
        
        function metrics = computeMetrics(~,input)
            outputSize = Helper.ComputeObjectSize(input);
            metrics = Metric(1,1,outputSize);
        end
    end
end
