classdef SegmentsCreator < handle
    
    properties (Access = public)
        preprocessedSignalsLoader;
        segmentationAlgorithm;
    end
    
    methods (Access = public)
        
        %segments the raw data based on a segmentation 
        %algorithm applied on the preprocessed data
        function segments = createSegments(obj)
            dataPerFile = obj.preprocessedSignalsLoader.loadOrCreateData();
            segments = obj.segmentationAlgorithm.segment(dataPerFile);
        end
        
        function str = toString(obj,recursive)
            if nargin == 1
                recursive = false;
            end
            
            str = "";
            if recursive
                str = obj.preprocessedSignalsLoader.preprocessor.toString();
            end
            
            segmentationAlgorithmStr = obj.segmentationAlgorithm.toString();
            
            if isempty(str)
                str = segmentationAlgorithmStr;
            else
                str = sprintf("%s_%s",str,segmentationAlgorithmStr);
            end
        end
    end
    
end