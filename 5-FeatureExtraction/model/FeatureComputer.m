classdef FeatureComputer < handle
    properties (Access = public)
        featureExtractor;
        range = [];
        signalAxis = 1;
    end
    
    methods (Access = public)
        function obj = FeatureComputer(featureExtractor,signalAxis,range)
            if nargin > 0
                obj.featureExtractor = featureExtractor;
                if nargin > 1
                    obj.signalAxis = signalAxis;
                    if nargin > 2
                        obj.range = range;
                    end
                end
            end
        end
        
        function feature = compute(obj,data)
            signal = data(obj.range.rangeStart:obj.range.rangeEnd,obj.signalAxis);
            feature = obj.featureExtractor.compute(signal);
        end
        
        function str = toString(obj)
            featureExtractorStr = obj.featureExtractor.toString();
            rangeStr = obj.range.toString();
            str = sprintf('%s_%d_%s',featureExtractorStr,obj.signalAxis,rangeStr);
        end
    end
end