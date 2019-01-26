classdef FeatureComputer < handle
    properties (Access = public)
        featureExtractor;%computer
        range = [];
        signalAxis = 1;
        numOutputSignals = 1;
    end
    
    methods (Access = public)
        function obj = FeatureComputer(featureExtractor,signalAxis,range)
            if nargin > 0
                obj.featureExtractor = featureExtractor;
                obj.signalAxis = signalAxis;
                obj.range = range;
            end
        end
        
        function nFeatures = getNFeatures(obj)
            nFeatures = obj.numOutputSignals;
        end
        
        function feature = compute(obj,data)
            if isempty(obj.range)
                signal = data(:,obj.signalAxis);
            else
                signal = data(obj.range.rangeStart:obj.range.rangeEnd,obj.signalAxis);
            end
            feature = obj.featureExtractor.compute(signal);
        end
        
        function str = toString(obj)
            featureExtractorStr = obj.featureExtractor.toString();
            rangeStr = obj.range.toString();
            signalStr = num2str(obj.signalAxis);
            signalStr = strrep(signalStr,' ','_');
            str = sprintf('%s_%s_%s',featureExtractorStr,signalStr,rangeStr);
        end
    end
end