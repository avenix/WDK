classdef NoOp < Computer

    methods (Access = public)
        
        function obj = NoOp()
            obj.name = 'noOp';
        end
        
        function out = compute(~, dataIn)
            out = dataIn;
        end
        
        function str = toString(~)
            str = '';
        end
    end
end