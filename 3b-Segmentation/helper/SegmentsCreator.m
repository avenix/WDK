classdef SegmentsCreator < handle
    
    properties (Access = public)
        data;
        preprocessedSignalsLoader;
        segmentationAlgorithm;
    end
    
    methods (Access = public)
        
        %segments the raw data based on a segmentation 
        %algorithm applied on the preprocessed data
        function segments = createSegments(obj)
            dataFiles = obj.preprocessedSignalsLoader.loadOrCreateData();
            segments = obj.segment(dataFiles);
            obj.addDataToSegments(segments);
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
                dataFile = dataFiles{i};
               segments{i} = obj.segmentationAlgorithm.segment(dataFile);
            end
        end
        
        function addDataToSegments(obj,segments)
            if isempty(obj.data)
                dataLoader = DataLoader();
                obj.data = dataLoader.loadAllDataFiles();
            end
            
            nFiles = length(segments);
            for i = 1 : nFiles
                segmentsCurrentFile = segments{i};
                dataCurrentFile = obj.data{i};
                for j = 1 : length(segmentsCurrentFile)
                    segment = segmentsCurrentFile(j);
                    segment.window = dataCurrentFile(segment.startSample:segment.endSample,:);
                end
                %segments{i} = segmentPreprocessedData;
            end
            
        end
    end
end