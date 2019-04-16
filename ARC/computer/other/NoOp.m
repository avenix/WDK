classdef NoOp < Computer

    methods (Access = public)
        
        function obj = NoOp()
            obj.name = 'noOp';
        end
        
        function out = compute(~, dataIn)
            out = dataIn;
        end
        
        function metrics = computeMetrics(~,input)
            outputSize = size(input,1) * size(input,2) * 4;
            metrics = Metric(0,0,outputSize);
        end
    end
end
