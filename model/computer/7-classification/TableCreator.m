classdef TableCreator < Computer
    
    methods (Access = public)
        
        function obj = TableCreator()
            obj.name = 'TableCreator';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        %creates a single table from a set of segments
        function table = compute(obj,segments)
            
            nSegments = length(segments);
            nFeatures = obj.featureExtractor.getNFeatures();
            shouldCreateLabelColumn = obj.areSegmentsLabeled(segments);
            nColumns = nFeatures + int32(shouldCreateLabelColumn);
            featureVectors = zeros(nSegments,nColumns);
            segmentsCounter = 0;
            
            for i = 1 : nSegments
                segment = segments(i);
                
                if  obj.shouldProcessLabel(segment.label)
                    
                    segmentsCounter = segmentsCounter + 1;
                    
                    featureVectors(segmentsCounter,1:nFeatures) = obj.featureExtractor.extractFeaturesForSegment(segment);
                    
                    if ~isempty(segment.label)
                        featureVectors(segmentsCounter,nColumns) = segment.label;
                    end
                end
            end
            
            table = array2table(featureVectors(1:segmentsCounter,:));
            if shouldCreateLabelColumn
                table.Properties.VariableNames = [obj.featureExtractor.getFeatureNames(), 'label'];
            end
            table = Table(table);
        end
    end
end