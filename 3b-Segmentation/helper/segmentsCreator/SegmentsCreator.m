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
        
        function str = toString(obj)
            segmentationAlgorithmStr = obj.segmentationAlgorithm.toString();
            str = sprintf('%s',segmentationAlgorithmStr);
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