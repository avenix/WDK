classdef SegmentsCreator < handle
    
    properties (Access = public)
        preprocessedSignalsLoader;
        segmentationAlgorithm;
    end
    
    methods (Access = public)
        
        function segments = createSegments(obj)
            dataFiles = obj.preprocessedSignalsLoader.loadOrCreateData();
            segments = obj.segment(dataFiles);
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
    
    methods (Access = private)
        
        function segments = segment(obj,dataFiles)
            nFiles = length(dataFiles);
            segments = cell(1,nFiles);
            
            for i = 1 : nFiles
                data = dataFiles{i};
                segments{i} = obj.segmentationAlgorithm.segment(data);
            end
        end
    end
end