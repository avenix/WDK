classdef SegmentsCreator < handle
    
    properties (Access = public)
        preprocessedSignalsLoader;
        segmentationAlgorithm;
    end
    
    methods (Access = public)
        
        %segments the raw data based on a segmentation 
        %algorithm applied on the preprocessed data
        function segments = createSegments(obj)
            dataFiles = obj.preprocessedSignalsLoader.loadOrCreateData();
            segments = obj.segmentationAlgorithm.segmentFiles(dataFiles);
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
            str = sprintf("%s_%s",str,segmentationAlgorithmStr);
        end
    end
    
    
end