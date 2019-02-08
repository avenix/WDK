classdef FeatureExtractor < Computer

    properties (Access = public)
        computers;
    end
    
    methods (Access = public)
        
        function obj = FeatureExtractor(computers)
            if nargin > 0 
                obj.computers = computers;
            end
            obj.name = 'FeatureExtractor';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        %creates a table from a set of segments
        function table = compute(obj,segments)
            nSegments = length(segments);
            nFeatures = length(obj.computers);
            shouldCreateLabelColumn = obj.areSegmentsLabeled(segments);
            nColumns = nFeatures + int32(shouldCreateLabelColumn);
            featureVectors = zeros(nSegments,nColumns);
            
            for i = 1 : nSegments
                segment = segments(i);
                for j = 1 : length(obj.computers)
                    featureVectors(i,j) = Computer.ExecuteChain(obj.computers{j},segment.window);
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
        
        function names = getFeatureNames(obj)
            nComputers = length(obj.computers);
            names = cell(1,nComputers);
            for i = 1 : nComputers
                featureName = sprintf('%s_%d',obj.computers{i}.toString(),i);
                names{i} = featureName;
            end
        end
        
        function str = toString(obj)
            str = "";
            if ~isempty(obj.computers)
                
                for i = 1 : length(obj.computers)
                    computerStr = obj.computerStringForIdx(i);
                    if ~isequal(computerStr,"")
                        str = sprintf('%s%s_',str,computerStr);
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        
        function labeled = areSegmentsLabeled(~,segments)
            labeled = false;
            if ~isempty(segments)
                if ~isempty(segments(1).label)
                    labeled = true;
                end
            end
        end
    end
    
    methods (Static)
        
        function featureExtractor = CreateAllFeatureExtractors(numSignals,segmentRanges)
            statisticalFeatureExtractors = FeatureExtractor.CreateAllStatisticalFeatureExtractors(numSignals,segmentRanges);
            featureExtractor = FeatureExtractor(statisticalFeatureExtractors);
        end
        
        function featureComputers = CreateAllStatisticalFeatureExtractors(numSignals,segmentRanges)
            
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
                        
                        featureComputer = SequentialComputer({rangeSelector,segmentWindowAccessor,axisSelector,featureExtractor});
                        featureComputers{featureExtractorCounter} = featureComputer;
                        featureExtractorCounter = featureExtractorCounter + 1;
                    end
                end
            end
        end
        
        function featureExtractors = CreateDefaultFeatureExtractors()
            featureExtractors = {Min(), Max(), Mean(), Variance(), STD(), Median(), AUC(), AAV()};
            %featureExtractorHandles = {@min,@max,@mean,@var,@std,@median,@trapz,@aav,...
            %   @mad,@iqr,@rms,@mySkewness,@myKurtosis};
        end
        
        function axisSelectors = CreateAxisSelectorsForSignals(numSignals)
            axisSelectors = repmat(AxisSelector,1,numSignals);
            for i = 1 : numSignals
                axisSelectors(i) = AxisSelector(i);
            end
        end
        
        function rangeSelectors = CreateRangeSelectorsForRanges(ranges)
            nRanges = length(ranges);
            rangeSelectors = repmat(RangeSelector,1,nRanges);
            for i = 1 : nRanges
                range = ranges(i);
                rangeSelectors(i) = RangeSelector(range.rangeStart,range.rangeEnd);
            end
        end
        
    end
end