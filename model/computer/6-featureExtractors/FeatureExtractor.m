classdef FeatureExtractor < CompositeComputer
    
    methods (Access = public)
        
        function obj = FeatureExtractor(computers)
            obj = obj@CompositeComputer(computers);
            
            obj.name = 'FeatureExtractor';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        function table = compute(obj,segments)
            table = obj.createTable(segments);
        end
    end
    
    methods (Access = private)
        
        %creates a single table from a set of segments
        function table = createTable(obj,segments)
            
            nSegments = length(segments);
            nFeatures = length(obj.computers);
            shouldCreateLabelColumn = obj.areSegmentsLabeled(segments);
            nColumns = nFeatures + int32(shouldCreateLabelColumn);
            featureVectors = zeros(nSegments,nColumns);
            
            for i = 1 : nSegments
                segment = segments(i);
                
                for j = 1 : length(obj.computers)
                    featureVectors(i,j) = obj.computers{j}.compute(segment);
                end
            end
            
            if shouldCreateLabelColumn
                for i = 1 : nSegments
                    segment = segments(i);
                    featureVectors(i,nColumns) = segment.label;
                end
            end
            
            table = array2table(featureVectors);
            if shouldCreateLabelColumn
                table.Properties.VariableNames = [obj.getFeatureNames(), 'label'];
            end
            table = Table(table);
        end
        
        function labeled = areSegmentsLabeled(~,segments)
            labeled = false;
            if ~isempty(segments)
                if ~isempty(segments(1).label)
                    labeled = true;
                end
            end
        end
        
        function featureNames = getFeatureNames(obj)
            nFeatures = length(obj.computers);
            featureNames = cell(1,nFeatures);
            for i = 1 : nFeatures
                %featureNames{i} = obj.computers{i}.toString(); % these
                %names are too long
                featureNames{i} = sprintf('var_%d',i);
            end
        end
    end
    
    methods (Static)
        
        function featureExtractor = CreateDefaultFeatureExtractors(numSignals,segmentRanges)
            statisticalFeatureExtractors = FeatureExtractor.CreateStatisticalFeatureExtractors(numSignals,segmentRanges);
            featureExtractor = FeatureExtractor(statisticalFeatureExtractors);
        end
        
        function featureComputers = CreateStatisticalFeatureExtractors(numSignals,segmentRanges)
            
            featureExtractors = FeatureExtractor.createDefaultFeatureExtractionComputers();
            axisSelectors = FeatureExtractor.createAxisSelectorsForSignals(numSignals);
            rangeSelectors = FeatureExtractor.createRangeSelectorsForRanges(segmentRanges);
            
            nFeatureExtractors = length(featureExtractors);
            nAxisSelectors = length(axisSelectors);
            nRangeSelectors = length(segmentRanges);
            
            nFeatureComputers = nFeatureExtractors * numSignals * nRangeSelectors;
            
            featureComputers = cell(1,nFeatureComputers);
            featureExtractorCounter = 1;
            
            segmentWindowAccessor = Change('window');
            
            for featureExtractorIdx = 1 : nFeatureExtractors
                
                featureExtractor = featureExtractors{featureExtractorIdx};
                
                for axisSelectorIdx = 1 : nAxisSelectors
                    
                    axisSelector = axisSelectors(axisSelectorIdx);
                    
                    for rangeSelectorIdx = 1 : nRangeSelectors
                        
                        rangeSelector = rangeSelectors(rangeSelectorIdx);
                        
                        featureComputer = SequentialComputer({rangeSelector,axisSelector,segmentWindowAccessor,featureExtractor});
                        featureComputers{featureExtractorCounter} = featureComputer;
                        featureExtractorCounter = featureExtractorCounter + 1;
                    end
                end
            end
        end
        
        function featureExtractors = createDefaultFeatureExtractionComputers()
            featureExtractors = {Min(), Max(), Mean(), Median()};
            %featureExtractorHandles = {@min,@max,@mean,@var,@std,@median,@trapz,@aav,...
            %   @mad,@iqr,@rms,@mySkewness,@myKurtosis};
        end
        
        function axisSelectors = createAxisSelectorsForSignals(numSignals)
            axisSelectors = repmat(SegmentAxisSelector,1,numSignals);
            for i = 1 : numSignals
                axisSelectors(i) = SegmentAxisSelector(i);
            end
        end
        
        function rangeSelectors = createRangeSelectorsForRanges(ranges)
            nRanges = length(ranges);
            rangeSelectors = repmat(RangeSelector,1,nRanges);
            for i = 1 : nRanges
                range = ranges(i);
                rangeSelectors(i) = RangeSelector(range.rangeStart,range.rangeEnd);
            end
        end
        
    end
end